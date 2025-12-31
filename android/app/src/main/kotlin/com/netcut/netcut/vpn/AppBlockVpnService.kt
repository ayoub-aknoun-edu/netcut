package com.netcut.netcut.vpn

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import java.io.FileInputStream
import java.util.concurrent.atomic.AtomicBoolean

class AppBlockVpnService : VpnService() {

    companion object {
        const val EXTRA_BLOCKED_PACKAGES = "blockedPackages"
        const val ACTION_START_OR_UPDATE = "com.netcut.netcut.vpn.action.START_OR_UPDATE"
        const val ACTION_STOP = "com.netcut.netcut.vpn.action.STOP"
        private const val CHANNEL_ID = "netcut_vpn"
        private const val NOTIF_ID = 1001

        @Volatile
        var isRunning: Boolean = false
            private set
    }

    private var tun: ParcelFileDescriptor? = null
    private var workerThread: Thread? = null
    private var tunInput: FileInputStream? = null
    private val stopFlag = AtomicBoolean(false)

    @Volatile
    private var lastBlocked: Set<String> = emptySet()

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Explicit stop request
        if (intent?.action == ACTION_STOP) {
            stopEverything()
            return Service.START_NOT_STICKY
        }

        val incoming = intent?.getStringArrayListExtra(EXTRA_BLOCKED_PACKAGES) ?: arrayListOf()

        // Normalize + validate early so:
        // 1) our "did anything change?" check is stable
        // 2) we never accidentally establish an all-app VPN
        val blocked = incoming
            .asSequence()
            .map { it.trim() }
            .filter { it.isNotEmpty() }
            // Never try to route the host app itself into the VPN.
            // With an allowed list, excluding it means it simply bypasses the VPN.
            .filter { it != packageName }
            .filter {
                try {
                    packageManager.getPackageInfo(it, 0)
                    true
                } catch (_: Throwable) {
                    false
                }
            }
            .distinct()
            .toCollection(ArrayList())

        // Safety: never run as "all-app VPN" accidentally.
        // Also used when Android restarts a sticky service with a null intent.
        if (blocked.isEmpty()) {
            stopEverything()
            return Service.START_NOT_STICKY
        }

        val nextSet = blocked.toSet()
        // Skip unnecessary rebuilds if nothing changed.
        if (isRunning && nextSet == lastBlocked && tun != null) {
            startInForeground(blocked.size)
            return Service.START_STICKY
        }

        lastBlocked = nextSet

        startInForeground(blocked.size)
        restartTun(blocked)
        isRunning = (tun != null)
        return Service.START_STICKY
    }

    override fun onRevoke() {
        stopEverything()
        super.onRevoke()
    }

    override fun onDestroy() {
        stopEverything()
        super.onDestroy()
    }

    private fun restartTun(blockedPackages: ArrayList<String>) {
        stopWorker()
        stopFlag.set(false)

        // IMPORTANT: If the allowed list ends up empty, Android routes ALL apps through the VPN
        // (and since this VPN intentionally drops packets, that would block everything).
        if (blockedPackages.isEmpty()) {
            stopEverything()
            return
        }

        val builder = Builder().apply {
            setSession("NetCut (local VPN)")
            setMtu(1500)

            // Route traffic into TUN for allowed apps.
            // Include IPv4 and IPv6 so apps cannot bypass blocking via IPv6.
            addAddress("10.0.0.2", 32)
            addRoute("0.0.0.0", 0)
            addAddress("fd00:1:fd00:1:fd00:1:fd00:1", 128)
            addRoute("::", 0)

            // Only these apps are routed into our VPN (and thus blocked).
            // Do NOT call addDisallowedApplication() in this mode (AOSP forbids mixing lists).
            for (pkg in blockedPackages) {
                try {
                    addAllowedApplication(pkg)
                } catch (_: Throwable) {
                    // ignore invalid/unavailable apps
                }
            }
        }

        tun = builder.establish()
        val fd = tun?.fileDescriptor
        if (tun == null || fd == null) {
            stopWorker()
            return
        }

        // Read and drop packets. Reading prevents the kernel buffer from filling up.
        tunInput = FileInputStream(fd)
        workerThread = Thread {
            val buffer = ByteArray(32767)
            while (!stopFlag.get() && !Thread.currentThread().isInterrupted) {
                try {
                    val read = tunInput?.read(buffer) ?: break
                    if (read <= 0) break
                    // Intentionally drop packets.
                } catch (_: Throwable) {
                    break
                }
            }
        }.apply {
            name = "NetCutVpnWorker"
            isDaemon = true
            start()
        }
    }

    private fun startInForeground(blockedCount: Int) {
        val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= 26) {
            nm.createNotificationChannel(
                NotificationChannel(CHANNEL_ID, "NetCut VPN", NotificationManager.IMPORTANCE_LOW)
            )
        }

        val notif: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentTitle("NetCut is blocking apps")
            .setContentText("$blockedCount apps blocked")
            .setOngoing(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()

        val fgsType =
            if (Build.VERSION.SDK_INT >= 34) ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE else 0

        ServiceCompat.startForeground(this, NOTIF_ID, notif, fgsType)
    }

    private fun stopEverything() {
        stopWorker()
        isRunning = false
        lastBlocked = emptySet()

        // Stop foreground state (and remove the notification) in a compat way.
        try {
            ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
        } catch (_: Throwable) {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }

        stopSelf()
    }

    private fun stopWorker() {
        stopFlag.set(true)

        try {
            tunInput?.close()
        } catch (_: Throwable) {
        }
        tunInput = null

        workerThread?.interrupt()
        try {
            workerThread?.join(300)
        } catch (_: Throwable) {
        }
        workerThread = null

        try {
            tun?.close()
        } catch (_: Throwable) {
        }
        tun = null
    }
}
