package com.example.native_channel_app

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StringCodec

class MainActivity: FlutterActivity() {
    // Battery channel
    private val BATTERY_CHANNEL = "samples.flutter.dev/battery"

    // Chat channel
    private val CHAT_CHANNEL = "samples.flutter.dev/chat"
    private lateinit var chatChannel: BasicMessageChannel<String>

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // 🔹 Battery MethodChannel
        MethodChannel(messenger, BATTERY_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()
                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }

        // 🔹 Chat BasicMessageChannel
        chatChannel = BasicMessageChannel(messenger, CHAT_CHANNEL, StringCodec.INSTANCE)

        chatChannel.setMessageHandler { message, reply ->
            // Reply back to Flutter immediately
            reply.reply("Native delivered: $message")

            // Simulate async response
            Handler(Looper.getMainLooper()).postDelayed({
                chatChannel.send("Hey! I got your message: $message")
            }, 1000)
        }
    }

    // 🔹 Helper: Get battery level
    private fun getBatteryLevel(): Int {
        return if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext)
                .registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            intent?.let {
                val level = it.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                val scale = it.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
                (level * 100) / scale
            } ?: -1
        }
    }
}