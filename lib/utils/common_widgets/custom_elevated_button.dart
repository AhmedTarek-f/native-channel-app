import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.buttonTitle,
    this.backgroundColor,
    this.height,
    this.width,
    this.titleStyle,
    this.borderColor,
  });

  final void Function()? onPressed;
  final String buttonTitle;
  final Color? backgroundColor;
  final double? height, width;
  final TextStyle? titleStyle;
  final Color? borderColor;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: backgroundColor ?? Colors.white,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        minimumSize: Size(
          width ?? MediaQuery.sizeOf(context).width,
          height ?? 48,
        ),
        side: borderColor != null
            ? BorderSide(color: borderColor!)
            : const BorderSide(color: Colors.blueAccent),
      ),
      onPressed: onPressed,
      child: FittedBox(
        child: Text(
          buttonTitle,
          style:
              titleStyle ??
              const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.blueAccent,
              ),
        ),
      ),
    );
  }
}
