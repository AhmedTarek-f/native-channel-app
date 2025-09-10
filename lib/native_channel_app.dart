import 'package:flutter/material.dart';

import 'features/live_chat/views/live_chat_view.dart';

class NativeChannelApp extends StatelessWidget {
  const NativeChannelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Native Channels',
      debugShowCheckedModeBanner: false,
      home: LiveChatView(),
    );
  }
}
