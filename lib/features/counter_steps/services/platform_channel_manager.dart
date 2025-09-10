import 'dart:async';

import 'package:flutter/services.dart';
import 'package:native_battery_level/features/counter_steps/models/step_data.dart';
import 'package:native_battery_level/features/counter_steps/services/platform_channel_error.dart';

class PlatformChannelManager {
  static const String _channelName = 'com.example.step_counter';
  static const MethodChannel _methodChannel = MethodChannel('$_channelName/method');
  static const EventChannel _eventChannel = EventChannel('$_channelName/event');

  static StreamSubscription<dynamic>? _eventSubscription;
  static final StreamController<StepData> _stepDataController = 
      StreamController<StepData>.broadcast();

  static Stream<StepData> get stepDataStream => _stepDataController.stream;

  static Future<void> initialize() async {
    try {
      _eventSubscription = _eventChannel
          .receiveBroadcastStream()
          .handleError(_handleEventChannelError)
          .listen(_handleStepDataEvent);

      print('Platform channels initialized successfully');
    } catch (e) {
      throw PlatformChannelError(
        type: PlatformChannelErrorType.unknownError,
        message: 'Failed to initialize platform channels: $e'
      );
    }
  }

  static Future<Map<String, dynamic>> startStepCountingService() async {
    try {
      final result = await _methodChannel.invokeMethod('startService');
      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      throw PlatformChannelError.fromPlatformException(e);
    }
  }

  static Future<Map<String, bool>> checkPermissions() async {
    try {
      final result = await _methodChannel.invokeMethod('checkPermissions');
      return Map<String, bool>.from(result ?? {});
    } on PlatformException catch (e) {
      throw PlatformChannelError.fromPlatformException(e);
    }
  }

  static Future<Map<String, dynamic>> stopStepCountingService() async {
    try {
      final result = await _methodChannel.invokeMethod('stopService');
      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      throw PlatformChannelError.fromPlatformException(e);
    }
  }

  static void _handleStepDataEvent(dynamic event) {
    try {
      if (event is Map) {
        final stepData = StepData.fromMap(Map<String, dynamic>.from(event));
        _stepDataController.add(stepData);
      }
    } catch (e) {
      _stepDataController.addError(
        PlatformChannelError(
          type: PlatformChannelErrorType.invalidData,
          message: 'Invalid step data received: $e'
        )
      );
    }
  }

  static void _handleEventChannelError(dynamic error) {
    if (error is PlatformException) {
      final channelError = PlatformChannelError.fromPlatformException(error);
      _stepDataController.addError(channelError);
    }
  }

  static Future<void> dispose() async {
    await _eventSubscription?.cancel();
    await _stepDataController.close();
  }
}