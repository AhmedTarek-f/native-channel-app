package com.example.native_channel_app
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.EventChannel

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
import android.os.Bundle
import android.util.Log
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.example.native_channel_app.SecurityValidator
import com.example.native_channel_app.StepCounterService


class MainActivity: FlutterActivity() {
    // Battery channel
    private val BATTERY_CHANNEL = "samples.flutter.dev/battery"

    // Chat channel
    private val CHAT_CHANNEL = "samples.flutter.dev/chat"
    private lateinit var chatChannel: BasicMessageChannel<String>
    private val BATTERY_CHANNEL = "samples.flutter.dev/battery"
    private val CHANNEL_NAME = "com.example.step_counter"
    private val METHOD_CHANNEL = "$CHANNEL_NAME/method"
    private val EVENT_CHANNEL = "$CHANNEL_NAME/event"

    // Channel properties
    private var stepMethodChannel: MethodChannel? = null
    private var stepEventChannel: EventChannel? = null

    // Permissions
    private val REQUIRED_PERMISSIONS = arrayOf(Manifest.permission.ACTIVITY_RECOGNITION)
    private val PERMISSION_REQUEST_CODE = 1001

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // 🔹 Battery MethodChannel
        MethodChannel(messenger, BATTERY_CHANNEL).setMethodCallHandler { call, result ->

        // Battery channel (existing)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL).setMethodCallHandler { call, result ->
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

        // Step counter channels
        setupStepCounterChannels(flutterEngine)
    }

    private fun setupStepCounterChannels(engine: FlutterEngine) {
        // Method Channel
        stepMethodChannel = MethodChannel(engine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        stepMethodChannel?.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            handleStepMethodCall(call, result)
        }

        // Event Channel
        stepEventChannel = EventChannel(engine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
        stepEventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                StepCounterService.setEventSink(events)
            }

            override fun onCancel(arguments: Any?) {
                StepCounterService.setEventSink(null)
            }
        })
    }

    private fun handleStepMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "startService" -> startStepCounterService(result)
                "stopService" -> stopStepCounterService(result)
                "checkPermissions" -> checkPermissions(result)
                "requestPermissions" -> requestStepPermissions(result)
                "validateData" -> validateInputData(call, result)
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Error handling method call: ${call.method}", e)
            result.error("PLATFORM_ERROR", e.message, null)
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

    private fun startStepCounterService(result: MethodChannel.Result) {
        if (!hasRequiredPermissions()) {
            result.error("PERMISSION_DENIED", "Required permissions not granted", null)
            return
        }

        try {
            val intent = Intent(this, StepCounterService::class.java)
            if (VERSION.SDK_INT >= VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            result.success(mapOf("success" to true, "message" to "Service started"))
        } catch (e: Exception) {
            result.error("SERVICE_ERROR", "Failed to start service: ${e.message}", null)
        }
    }

    private fun stopStepCounterService(result: MethodChannel.Result) {
        try {
            val intent = Intent(this, StepCounterService::class.java)
            stopService(intent)
            result.success(mapOf("success" to true, "message" to "Service stopped"))
        } catch (e: Exception) {
            result.error("SERVICE_ERROR", "Failed to stop service: ${e.message}", null)
        }
    }

    private fun hasRequiredPermissions(): Boolean =
        REQUIRED_PERMISSIONS.all {
            ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED
        }

    private fun checkPermissions(result: MethodChannel.Result) {
        result.success(hasRequiredPermissions())
    }

    private fun requestStepPermissions(result: MethodChannel.Result) {
        if (hasRequiredPermissions()) {
            result.success(true)
            return
        }
        ActivityCompat.requestPermissions(this, REQUIRED_PERMISSIONS, PERMISSION_REQUEST_CODE)
        result.success(true)
    }

    private fun validateInputData(call: MethodCall, result: MethodChannel.Result) {
        @Suppress("UNCHECKED_CAST")
        val data = call.arguments as? Map<String, Any?>

        if (data == null) {
            result.error("INVALID_DATA", "Data cannot be null", null)
            return
        }

        val isValid = SecurityValidator.validateSensorData(data)
        result.success(mapOf("isValid" to isValid))
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            // Handle permission results if needed
        }
    }
}