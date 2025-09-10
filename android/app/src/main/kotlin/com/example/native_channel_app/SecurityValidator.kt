package com.example.native_channel_app

class SecurityValidator {
    companion object {
        fun validateStepCount(value: Any?): Boolean {
            if (value !is Number) return false
            val intValue = value.toInt()
            return intValue >= 0 && intValue <= 1000000
        }

        fun validateSensorData(data: Map<String, Any?>?): Boolean {
            if (data == null) return false

            if (!data.containsKey("timestamp") || !data.containsKey("value")) {
                return false
            }

            val timestamp = data["timestamp"] as? Long ?: return false
            val now = System.currentTimeMillis()
            if (kotlin.math.abs(now - timestamp) > 3600000) return false

            return true
        }

        fun sanitizeInput(input: String?): String {
            return input?.replace(Regex("[<>\"'\${}]"), "") ?: ""
        }
    }
}