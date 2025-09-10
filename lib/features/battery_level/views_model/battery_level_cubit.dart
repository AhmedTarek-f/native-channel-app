import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_battery_level/core/state_status/state_status.dart';
import 'package:native_battery_level/features/battery_level/views_model/battery_level_intent.dart';
import 'package:native_battery_level/features/battery_level/views_model/battery_level_state.dart';

class BatteryLevelCubit extends Cubit<BatteryLevelState> {
  BatteryLevelCubit() : super(const BatteryLevelState());
  final _platform = const MethodChannel('samples.flutter.dev/battery');

  Future<void> doIntent({required BatteryLevelIntent intent}) async {
    switch (intent) {
      case GetBatteryLevelIntent():
        await _getBatteryLevel();
    }
  }

  Future<void> _getBatteryLevel() async {
    try {
      emit(state.copyWith(batteryStatus: const StateStatus.loading()));
      final result = await _platform.invokeMethod<int>('getBatteryLevel');
      emit(
        state.copyWith(
          batteryStatus: StateStatus.success('Battery level at $result % .'),
        ),
      );
    } on PlatformException catch (e) {
      emit(
        state.copyWith(
          batteryStatus: StateStatus.failure(
            "Failed to get battery level: '${e.message}'.",
          ),
        ),
      );
    }
  }
}
