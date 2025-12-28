package com.netcut.netcut

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.net.VpnService
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.activity.result.ActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import com.netcut.netcut.vpn.AppBlockVpnService
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterFragmentActivity() {

    private val channelName = "netcut/firewall"

    private var pendingStartVpn: Boolean = false
    private var pendingBlockedPackages: ArrayList<String>? = null
    private var pendingResult: MethodChannel.Result? = null


    private val vpnPermissionLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { res: ActivityResult ->
            val ok = (res.resultCode == Activity.RESULT_OK)

            if (ok && pendingStartVpn) {
                startVpnService(pendingBlockedPackages ?: arrayListOf())
            }

            pendingResult?.success(ok)
            pendingResult = null
            pendingBlockedPackages = null
            pendingStartVpn = false
        }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "listApps" -> result.success(listLaunchableApps())
                    "hasVpnPermission" -> result.success(VpnService.prepare(this) == null)

                    "requestVpnPermission" -> {
                        requestVpnPermissionOnly(result)
                    }

                    "startVpn" -> {
                        val args = call.arguments as Map<*, *>
                        val pkgs = (args["blockedPackages"] as List<*>).map { it.toString() }
                        startVpnWithPermission(pkgs, result)
                    }

                    "getSdkInt" -> result.success(android.os.Build.VERSION.SDK_INT)
                    "stopVpn" -> {
                        stopService(Intent(this, AppBlockVpnService::class.java))
                        result.success(null)
                    }

                    "isVpnRunning" -> result.success(AppBlockVpnService.isRunning)

                    "openBatterySettings" -> {
                        openBatterySettings()
                        result.success(null)
                    }

                    "requestIgnoreBatteryOptimizations" -> {
                        requestIgnoreBatteryOptimizations()
                        result.success(null)
                    }

                    "isIgnoringBatteryOptimizations" -> {
                        result.success(isIgnoringBatteryOptimizations())
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun startVpnWithPermission(blockedPackages: List<String>, result: MethodChannel.Result) {
        val prepareIntent = VpnService.prepare(this)
        if (prepareIntent != null) {
            pendingStartVpn = true
            pendingBlockedPackages = ArrayList(blockedPackages)
            pendingResult = result
            vpnPermissionLauncher.launch(prepareIntent)
        } else {
            startVpnService(ArrayList(blockedPackages))
            result.success(true)
        }
    }


    private fun requestVpnPermissionOnly(result: MethodChannel.Result) {
        val prepareIntent = VpnService.prepare(this)
        if (prepareIntent != null) {
            pendingStartVpn = false
            pendingBlockedPackages = null
            pendingResult = result
            vpnPermissionLauncher.launch(prepareIntent)
        } else {
            result.success(true)
        }
    }



    private fun startVpnService(blockedPackages: ArrayList<String>) {
        val intent = Intent(this, AppBlockVpnService::class.java).apply {
            putStringArrayListExtra(AppBlockVpnService.EXTRA_BLOCKED_PACKAGES, blockedPackages)
        }
        ContextCompat.startForegroundService(this, intent)
    }

    private fun listLaunchableApps(): List<Map<String, Any?>> {
        val pm = packageManager
        val mainIntent = Intent(Intent.ACTION_MAIN, null).addCategory(Intent.CATEGORY_LAUNCHER)

        val resolved = if (Build.VERSION.SDK_INT >= 33) {
            pm.queryIntentActivities(mainIntent, PackageManager.ResolveInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            pm.queryIntentActivities(mainIntent, 0)
        }

        return resolved.mapNotNull { ri ->
            val ai = ri.activityInfo?.applicationInfo ?: return@mapNotNull null
            val pkg = ai.packageName ?: return@mapNotNull null
            val label = pm.getApplicationLabel(ai)?.toString() ?: pkg

            val iconBytes: ByteArray? = try {
                val drawable = pm.getApplicationIcon(ai)
                drawableToPng(drawable)
            } catch (_: Throwable) {
                null
            }

            mapOf(
                "packageName" to pkg,
                "label" to label,
                "icon" to iconBytes
            )
        }
    }

    private fun drawableToPng(drawable: Drawable): ByteArray {
        val bitmap: Bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
            drawable.bitmap
        } else {
            val w = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 96
            val h = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 96
            Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888).also { bmp ->
                val canvas = Canvas(bmp)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
            }
        }

        val bos = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, bos)
        return bos.toByteArray()
    }

    private fun openBatterySettings() {
        val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun requestIgnoreBatteryOptimizations() {
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
        intent.data = Uri.parse("package:$packageName")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }
}
