import 'dart:async';

import 'package:flutter/material.dart';
import 'package:native_battery_level/features/counter_steps/models/step_data.dart';
import 'package:native_battery_level/features/counter_steps/services/platform_channel_error.dart';
import 'package:native_battery_level/features/counter_steps/services/platform_channel_manager.dart';

class StepCounterHomePage extends StatefulWidget {
  static const String routeName = "/StepCounterHomePage";
  const StepCounterHomePage({super.key});

  @override
  _StepCounterHomePageState createState() => _StepCounterHomePageState();
}

class _StepCounterHomePageState extends State<StepCounterHomePage> {
  StepData? currentStepData;
  bool isServiceRunning = false;
  bool isInitialized = false;
  PlatformChannelError? lastError;

  StreamSubscription<StepData>? stepDataSubscription;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await PlatformChannelManager.initialize();
      _setupStepDataListener();

      setState(() {
        isInitialized = true;
        lastError = null;
      });
    } catch (e) {
      setState(() {
        lastError = e is PlatformChannelError
            ? e
            : PlatformChannelError(
                type: PlatformChannelErrorType.unknownError,
                message: 'Initialization failed: $e',
              );
      });
    }
  }

  void _setupStepDataListener() {
    stepDataSubscription = PlatformChannelManager.stepDataStream
        .handleError((error) {
          setState(() {
            lastError = error is PlatformChannelError
                ? error
                : PlatformChannelError(
                    type: PlatformChannelErrorType.unknownError,
                    message: 'Stream error: $error',
                  );
          });
        })
        .listen((stepData) {
          setState(() {
            currentStepData = stepData;
            lastError = null;
          });
        });
  }

  Future<void> _startService() async {
    if (!isInitialized) return;

    try {
      final result = await PlatformChannelManager.startStepCountingService();

      if (result['success'] == true) {
        setState(() {
          isServiceRunning = true;
          lastError = null;
        });
        _showSnackBar('Step counting started successfully');
      }
    } catch (e) {
      final error = e is PlatformChannelError
          ? e
          : PlatformChannelError(
              type: PlatformChannelErrorType.serviceUnavailable,
              message: 'Failed to start service: $e',
            );

      setState(() {
        lastError = error;
      });

      _showSnackBar(error.userFriendlyMessage, isError: true);
    }
  }

  Future<void> _stopService() async {
    if (!isInitialized) return;

    try {
      final result = await PlatformChannelManager.stopStepCountingService();

      if (result['success'] == true) {
        setState(() {
          isServiceRunning = false;
          lastError = null;
        });
        _showSnackBar('Step counting stopped successfully');
      }
    } catch (e) {
      final error = e is PlatformChannelError
          ? e
          : PlatformChannelError(
              type: PlatformChannelErrorType.serviceUnavailable,
              message: 'Failed to stop service: $e',
            );

      setState(() {
        lastError = error;
      });

      _showSnackBar(error.userFriendlyMessage, isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    stepDataSubscription?.cancel();
    PlatformChannelManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Step Counter')),
      body: !isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (lastError != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.red.shade100,
                    child: Text(lastError!.userFriendlyMessage),
                  ),

                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Steps Today',
                          style: TextStyle(fontSize: 24),
                        ),
                        Text(
                          '${currentStepData?.steps ?? 0}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: isServiceRunning
                                  ? null
                                  : _startService,
                              child: const Text('Start Counting'),
                            ),
                            ElevatedButton(
                              onPressed: !isServiceRunning
                                  ? null
                                  : _stopService,
                              child: const Text('Stop Counting'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
