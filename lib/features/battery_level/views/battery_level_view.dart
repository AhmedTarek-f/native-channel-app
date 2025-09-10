import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_battery_level/features/battery_level/views/widgets/battery_level_app_bar.dart';
import 'package:native_battery_level/features/battery_level/views/widgets/battery_level_view_body.dart';
import 'package:native_battery_level/features/battery_level/views_model/battery_level_cubit.dart';

class BatteryLevelView extends StatelessWidget {
  static const String routeName = "/batteryLevelView";
  const BatteryLevelView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BatteryLevelCubit>(
      create: (context) => BatteryLevelCubit(),
      child: const Scaffold(
        appBar: BatteryLevelAppBar(),
        body: BatteryLevelViewBody(),
      ),
    );
  }
}
