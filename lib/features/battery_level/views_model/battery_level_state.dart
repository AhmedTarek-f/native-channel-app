import 'package:equatable/equatable.dart';
import 'package:native_battery_level/core/state_status/state_status.dart';

class BatteryLevelState extends Equatable {
  final StateStatus<String> batteryStatus;
  const BatteryLevelState({
    this.batteryStatus = const StateStatus.success("Unknown battery level"),
  });

  BatteryLevelState copyWith({StateStatus<String>? batteryStatus}) {
    return BatteryLevelState(
      batteryStatus: batteryStatus ?? this.batteryStatus,
    );
  }

  @override
  List<Object?> get props => [batteryStatus];
}
