import 'package:flutter/material.dart';
import 'package:native_battery_level/features/home/views/widgets/home_app_bar.dart';
import 'package:native_battery_level/features/home/views/widgets/home_view_body.dart';

class HomeView extends StatelessWidget {
  static const String routeName = "/home";
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(appBar: HomeAppBar(), body: HomeViewBody());
  }
}
