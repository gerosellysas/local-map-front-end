import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final double? width;
  final String? buttonText;
  final void Function()? onPressed;

  const CustomButton({
    super.key,
    this.width = 150,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: Colors.blue,
      padding: const EdgeInsets.all(10),
      child: Container(
        height: 15,
        width: width,
        alignment: Alignment.center,
        child: Text(
          buttonText!,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}
