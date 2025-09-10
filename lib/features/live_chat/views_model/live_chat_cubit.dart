import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_battery_level/core/state_status/state_status.dart';
import 'package:native_battery_level/features/live_chat/views_model/live_chat_intent.dart';
import 'package:native_battery_level/features/live_chat/views_model/live_chat_state.dart';

class LiveChatCubit extends Cubit<LiveChatState> {
  LiveChatCubit() : super(const LiveChatState());
  final BasicMessageChannel<String> _chatChannel = const BasicMessageChannel(
    'samples.flutter.dev/chat',
    StringCodec(),
  );
  late final TextEditingController messageController;
  List<String> messages = [];

  Future<void> doIntent({required LiveChatIntent intent}) async {
    switch (intent) {
      case LiveChatInitializationIntent():
        _onInit();
      case SendMessageIntent():
        await _sendMessage();
    }
  }

  void _onInit() {
    messageController = TextEditingController();
    _chatChannel.setMessageHandler((message) async {
      messages.add("Friend: $message");
      emit(state.copyWith(sendMessageStatus: StateStatus.success(null)));
      return "Flutter received: $message";
    });
  }

  Future<void> _sendMessage() async {
    final text = messageController.text;
    if (text.isEmpty) return;
    emit(state.copyWith(sendMessageStatus: const StateStatus.loading()));
    try {
      await _chatChannel.send(text);
      if (isClosed) return;
      messages.add("Me: $text");
      messageController.clear();
      emit(state.copyWith(sendMessageStatus: StateStatus.success(null)));
    } catch (error) {
      emit(
        state.copyWith(
          sendMessageStatus: StateStatus.failure(error.toString()),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    messageController.dispose();
    return super.close();
  }
}
