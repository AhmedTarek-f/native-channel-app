import 'package:flutter/material.dart';

class BatteryLevelAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const BatteryLevelAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "Battery Level",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
