import 'package:flutter/material.dart';
import 'package:native_battery_level/features/battery_level/views/battery_level_view.dart';
import 'package:native_battery_level/features/counter_steps/views/step_counter_home_page.dart';
import 'package:native_battery_level/features/live_chat/views/live_chat_view.dart';
import 'package:native_battery_level/utils/common_widgets/custom_elevated_button.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Spacer(),
          Expanded(
            child: CustomElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(BatteryLevelView.routeName);
              },
              buttonTitle: "Battery Level (MethodChannel)",
            ),
          ),
          const Spacer(),
          Expanded(
            child: CustomElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(StepCounterHomePage.routeName);
              },
              buttonTitle: "Steps Counter (All Channels Used)",
            ),
          ),
          const Spacer(),
          Expanded(
            child: CustomElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(LiveChatView.routeName);
              },
              buttonTitle: "Live Chat (BasicMessageChannel)",
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
