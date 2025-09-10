import 'package:flutter/material.dart';
import 'package:native_battery_level/features/battery_level/views/battery_level_view.dart';
import 'package:native_battery_level/features/counter_steps/views/step_counter_home_page.dart';
import 'package:native_battery_level/features/home/views/home_view.dart';
import 'package:native_battery_level/features/live_chat/views/live_chat_view.dart';

abstract class AppRouter {
  static Map<String, Widget Function(BuildContext)> routes = {
    HomeView.routeName: (_) => const HomeView(),
    BatteryLevelView.routeName: (_) => const BatteryLevelView(),
    StepCounterHomePage.routeName: (_) => const StepCounterHomePage(),
    LiveChatView.routeName: (_) => const LiveChatView(),
  };
}
