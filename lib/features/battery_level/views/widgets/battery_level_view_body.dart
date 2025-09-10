import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_battery_level/features/battery_level/views_model/battery_level_cubit.dart';
import 'package:native_battery_level/features/battery_level/views_model/battery_level_intent.dart';
import 'package:native_battery_level/features/battery_level/views_model/battery_level_state.dart';

class BatteryLevelViewBody extends StatelessWidget {
  const BatteryLevelViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCubit = BlocProvider.of<BatteryLevelCubit>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BlocBuilder<BatteryLevelCubit, BatteryLevelState>(
            builder: (context, state) => state.batteryStatus.isLoading
                ? ElevatedButton(
                    onPressed: () {},
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () async => await homeCubit.doIntent(
                      intent: GetBatteryLevelIntent(),
                    ),
                    child: const Text('Get Battery Level'),
                  ),
          ),
          BlocBuilder<BatteryLevelCubit, BatteryLevelState>(
            builder: (context, state) {
              if (state.batteryStatus.isLoading) {
                return const Text("Loading ...");
              } else if (state.batteryStatus.isFailure) {
                return Text(state.batteryStatus.errorMessage ?? "");
              } else {
                return Text(state.batteryStatus.data ?? "");
              }
            },
          ),
        ],
      ),
    );
  }
}
