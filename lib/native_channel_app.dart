import 'package:flutter/material.dart';
import 'package:native_battery_level/features/counter_steps/views/step_counter_home_page.dart';

class NativeChannelApp extends StatelessWidget {
  const NativeChannelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Channels',
      debugShowCheckedModeBanner: false,
      home: StepCounterHomePage(),
    );
  }
}
