import 'package:flutter/material.dart';
import 'package:native_battery_level/features/battery_level/views/battery_level_view.dart';

class NativeChannelApp extends StatelessWidget {
  const NativeChannelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Native Channels',
      debugShowCheckedModeBanner: false,
      home: BatteryLevelView(),
    );
  }
}
