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
        private const val CHANNEL_ID = "netcut_vpn"
        private const val NOTIF_ID = 1001

        @Volatile
        var isRunning: Boolean = false
            private set
    }

    private var tun: ParcelFileDescriptor? = null
    private var workerThread: Thread? = null
    private val stopFlag = AtomicBoolean(false)

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    val blocked = intent?.getStringArrayListExtra(EXTRA_BLOCKED_PACKAGES) ?: arrayListOf()

    // Safety: never run as "all-app VPN" accidentally
    if (blocked.isEmpty()) {
        stopEverything()
        return Service.START_NOT_STICKY
    }

    startInForeground(blocked.size)
    restartTun(blocked)
    isRunning = true
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
        stopFlag.set(true)
        workerThread?.interrupt()
        workerThread = null

        try { tun?.close() } catch (_: Throwable) {}
        tun = null

        stopFlag.set(false)

        val builder = Builder().apply {
            setSession("NetCut (local VPN)")
            setMtu(1500)

            // Minimal config: everything routes into TUN for allowed apps.
            addAddress("10.0.0.2", 32)
            addRoute("0.0.0.0", 0)

            // Only these apps are routed into our VPN (and thus blocked).
            for (pkg in blockedPackages) {
                try {
                    packageManager.getPackageInfo(pkg, 0)
                    addAllowedApplication(pkg)
                } catch (_: Throwable) {
                    // ignore missing apps
                }
            }
        }

        tun = builder.establish() ?: return
        val fd = tun?.fileDescriptor ?: return

        workerThread = Thread {
            val input = FileInputStream(fd)
            val buffer = ByteArray(32767)
            while (!stopFlag.get() && !Thread.currentThread().isInterrupted) {
                try {
                    val read = input.read(buffer)
                    if (read <= 0) break
                    // Drop packets = cut internet.
                } catch (_: Throwable) {
                    break
                }
            }
            try { input.close() } catch (_: Throwable) {}
        }.apply { start() }
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
        stopFlag.set(true)
        workerThread?.interrupt()
        workerThread = null

        try { tun?.close() } catch (_: Throwable) {}
        tun = null

        isRunning = false

        // Use legacy stopForeground for max compatibility
        @Suppress("DEPRECATION")
        stopForeground(true)

        stopSelf()
    }
}
