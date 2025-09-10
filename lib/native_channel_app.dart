import 'package:flutter/material.dart';
import 'package:native_battery_level/core/app_router.dart';
import 'package:native_battery_level/features/home/views/home_view.dart';

class NativeChannelApp extends StatelessWidget {
  const NativeChannelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Channels',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: HomeView.routeName,
      routes: AppRouter.routes,
    );
  }
}
