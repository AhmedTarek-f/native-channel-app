import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_battery_level/features/live_chat/views/widgets/live_chat_app_bar.dart';
import 'package:native_battery_level/features/live_chat/views/widgets/live_chat_view_body.dart';
import 'package:native_battery_level/features/live_chat/views_model/live_chat_cubit.dart';
import 'package:native_battery_level/features/live_chat/views_model/live_chat_intent.dart';

class LiveChatView extends StatelessWidget {
  const LiveChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LiveChatCubit>(
      create: (context) =>
          LiveChatCubit()..doIntent(intent: LiveChatInitializationIntent()),
      child: const Scaffold(appBar: LiveChatAppBar(), body: LiveChatViewBody()),
    );
  }
}
