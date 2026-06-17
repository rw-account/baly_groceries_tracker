package com.home_orders_tracker.app

import android.content.Context
import android.os.Build
import android.os.PowerManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity: FlutterActivity() {
    private val BATTERY_CHANNEL = "com.home_orders_tracker.app/battery_optimization"
    private val TIMEZONE_CHANNEL = "com.home_orders_tracker.app/local_timezone"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // قناة البطارية
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isIgnoringBatteryOptimizations" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        result.success(pm.isIgnoringBatteryOptimizations(packageName))
                    } else {
                        result.success(true)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // قناة التوقيت المحلي
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TIMEZONE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getLocalTimezone" -> {
                    result.success(TimeZone.getDefault().id)
                }
                else -> result.notImplemented()
            }
        }
    }
}