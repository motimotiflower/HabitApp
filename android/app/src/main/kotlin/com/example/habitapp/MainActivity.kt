package com.example.habitapp

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "habitapp/widget"
    private var channel: MethodChannel? = null
    private var pendingAction: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pendingAction = intent?.getStringExtra("widget_action")

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getLaunchAction" -> {
                        result.success(pendingAction)
                        pendingAction = null
                    }
                    "updateWidgets" -> {
                        HabitWidgetProvider.updateAll(this@MainActivity)
                        TaskWidgetProvider.updateAll(this@MainActivity)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val action = intent.getStringExtra("widget_action") ?: return
        pendingAction = action
        channel?.invokeMethod("openAction", action)
    }
}
