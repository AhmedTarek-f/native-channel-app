import 'package:flutter/services.dart';

enum PlatformChannelErrorType {
  permissionDenied,
  sensorUnavailable,
  serviceUnavailable,
  invalidData,
  unknownError
}

class PlatformChannelError extends Error {
  final PlatformChannelErrorType type;
  final String message;
  final String? code;
  final dynamic details;

  PlatformChannelError({
    required this.type,
    required this.message,
    this.code,
    this.details
  });

  factory PlatformChannelError.fromPlatformException(PlatformException e) {
    PlatformChannelErrorType type;

    switch (e.code) {
      case 'PERMISSION_DENIED':
        type = PlatformChannelErrorType.permissionDenied;
        break;
      case 'SENSOR_UNAVAILABLE':
        type = PlatformChannelErrorType.sensorUnavailable;
        break;
      case 'SERVICE_UNAVAILABLE':
        type = PlatformChannelErrorType.serviceUnavailable;
        break;
      default:
        type = PlatformChannelErrorType.unknownError;
    }

    return PlatformChannelError(
      type: type,
      message: e.message ?? 'Unknown platform error',
      code: e.code,
      details: e.details
    );
  }

  String get userFriendlyMessage {
    switch (type) {
      case PlatformChannelErrorType.permissionDenied:
        return 'Please grant permission to access motion sensors in your device settings.';
      case PlatformChannelErrorType.sensorUnavailable:
        return 'Motion sensors are not available on this device.';
      case PlatformChannelErrorType.serviceUnavailable:
        return 'Step counting service is temporarily unavailable. Please try again.';
      default:
        return 'An unexpected error occurred. Please contact support if this persists.';
    }
  }
}