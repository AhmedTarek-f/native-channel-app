package com.example.native_channel_app
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.EventChannel
import kotlin.math.sqrt

class StepCounterService : Service(), SensorEventListener {
    private lateinit var sensorManager: SensorManager
    private var stepCounterSensor: Sensor? = null
    private var accelerometerSensor: Sensor? = null

    private var initialStepCount: Float = -1f
    private var currentSessionSteps: Int = 0
    private var isUsingAccelerometer = false

    // Accelerometer step detection variables
    private var lastAcceleration = 0f
    private var currentAcceleration = 0f
    private var lastUpdate = 0L
    private val threshold = 12f

    companion object {
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "step_counter_channel"
        private var eventSink: EventChannel.EventSink? = null

        fun setEventSink(sink: EventChannel.EventSink?) {
            eventSink = sink
        }
    }

    override fun onCreate() {
        super.onCreate()

        try {
            initializeSensorManager()
            createNotificationChannel()
            startForegroundService()

            Log.d("StepCounterService", "Service created successfully")
        } catch (e: Exception) {
            Log.e("StepCounterService", "Failed to create service", e)
            handleServiceError(e)
        }
    }

    private fun initializeSensorManager() {
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager

        stepCounterSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)

        if (stepCounterSensor != null) {
            Log.d("StepCounterService", "Using hardware step counter")
            sensorManager.registerListener(this, stepCounterSensor, SensorManager.SENSOR_DELAY_NORMAL)
        } else {
            Log.d("StepCounterService", "Using accelerometer fallback")
            accelerometerSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

            if (accelerometerSensor != null) {
                isUsingAccelerometer = true
                sensorManager.registerListener(this, accelerometerSensor, SensorManager.SENSOR_DELAY_UI)
                lastUpdate = System.currentTimeMillis()
            } else {
                throw RuntimeException("No suitable sensors available")
            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Step Counter Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Tracks your steps in the background"
            }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun startForegroundService() {
        val notification = createNotification("Starting step counter...")
        startForeground(NOTIFICATION_ID, notification)
    }

    private fun createNotification(content: String): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Step Counter Active")
            .setContentText(content)
            .setSmallIcon(android.R.drawable.ic_menu_directions)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null) return

        try {
            when (event.sensor.type) {
                Sensor.TYPE_STEP_COUNTER -> handleStepCounterData(event)
                Sensor.TYPE_ACCELEROMETER -> handleAccelerometerData(event)
            }
        } catch (e: Exception) {
            Log.e("StepCounterService", "Error processing sensor data", e)
        }
    }

    private fun handleStepCounterData(event: SensorEvent) {
        val totalSteps = event.values[0]

        if (initialStepCount < 0) {
            initialStepCount = totalSteps
        }

        val sessionSteps = (totalSteps - initialStepCount).toInt()
        updateStepCount(sessionSteps)
    }

    private fun handleAccelerometerData(event: SensorEvent) {
        val currentTime = System.currentTimeMillis()

        if (currentTime - lastUpdate > 100) { // Update every 100ms
            val x = event.values[0]
            val y = event.values[1]
            val z = event.values[2]

            lastAcceleration = currentAcceleration
            currentAcceleration = sqrt(x * x + y * y + z * z)

            val delta = currentAcceleration - lastAcceleration

            if (delta > threshold) {
                currentSessionSteps++
                updateStepCount(currentSessionSteps)
            }

            lastUpdate = currentTime
        }
    }

    private fun updateStepCount(steps: Int) {
        currentSessionSteps = steps

        try {
            val data = mapOf(
                "steps" to steps,
                "timestamp" to System.currentTimeMillis(),
                "sensor_type" to if (isUsingAccelerometer) "accelerometer" else "step_counter",
                "accuracy" to if (isUsingAccelerometer) "medium" else "high"
            )

            eventSink?.success(data)
            updateNotification("Steps: $steps")

        } catch (e: Exception) {
            Log.e("StepCounterService", "Failed to send step count update", e)
        }
    }

    private fun updateNotification(content: String) {
        val notification = createNotification(content)
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    private fun handleServiceError(error: Exception) {
        eventSink?.error("SERVICE_ERROR", error.message, null)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // Handle accuracy changes if needed
    }

    override fun onDestroy() {
        super.onDestroy()
        sensorManager.unregisterListener(this)
        eventSink = null
    }

    override fun onBind(intent: Intent?): IBinder? = null
}