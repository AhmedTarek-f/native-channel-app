import 'package:equatable/equatable.dart';
import 'package:native_battery_level/core/state_status/state_status.dart';

class LiveChatState extends Equatable {
  final StateStatus<void> sendMessageStatus;

  const LiveChatState({this.sendMessageStatus = const StateStatus.initial()});

  LiveChatState copyWith({StateStatus<void>? sendMessageStatus}) {
    return LiveChatState(
      sendMessageStatus: sendMessageStatus ?? this.sendMessageStatus,
    );
  }

  @override
  List<Object?> get props => [sendMessageStatus];
}
