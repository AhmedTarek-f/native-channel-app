import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_battery_level/features/live_chat/views_model/live_chat_cubit.dart';
import 'package:native_battery_level/features/live_chat/views_model/live_chat_intent.dart';
import 'package:native_battery_level/features/live_chat/views_model/live_chat_state.dart';

class LiveChatViewBody extends StatelessWidget {
  const LiveChatViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final liveChatCubit = BlocProvider.of<LiveChatCubit>(context);
    return Column(
      children: [
        BlocBuilder<LiveChatCubit, LiveChatState>(
          buildWhen: (previous, current) => current.sendMessageStatus.isSuccess,
          builder: (context, state) => Expanded(
            child: ListView.builder(
              itemCount: liveChatCubit.messages.length,
              itemBuilder: (_, index) =>
                  ListTile(title: Text(liveChatCubit.messages[index])),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: liveChatCubit.messageController,
                  decoration: InputDecoration(
                    hint: Text("Send a Message"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
              ),
              BlocBuilder<LiveChatCubit, LiveChatState>(
                builder: (context, state) => state.sendMessageStatus.isLoading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      )
                    : IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async => await liveChatCubit.doIntent(
                          intent: SendMessageIntent(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
