import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_battery_level/features/battery_level/views_model/battery_level_cubit.dart';
import 'package:native_battery_level/features/battery_level/views_model/battery_level_intent.dart';
import 'package:native_battery_level/features/battery_level/views_model/battery_level_state.dart';
import 'package:native_battery_level/utils/common_widgets/custom_elevated_button.dart';

class BatteryLevelViewBody extends StatelessWidget {
  const BatteryLevelViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCubit = BlocProvider.of<BatteryLevelCubit>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<BatteryLevelCubit, BatteryLevelState>(
            builder: (context, state) {
              if (state.batteryStatus.isLoading) {
                return const Text("Loading ...");
              } else if (state.batteryStatus.isFailure) {
                return Text(state.batteryStatus.errorMessage ?? "");
              } else {
                return Text(
                  state.batteryStatus.data ?? "",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 62),
          BlocBuilder<BatteryLevelCubit, BatteryLevelState>(
            builder: (context, state) => state.batteryStatus.isLoading
                ? const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    child: CustomElevatedButton(
                      onPressed: () async => await homeCubit.doIntent(
                        intent: GetBatteryLevelIntent(),
                      ),
                      buttonTitle: 'Get Battery Level',
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
