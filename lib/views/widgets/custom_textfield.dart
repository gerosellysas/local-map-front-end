import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int? maxLength;
  final String? labelText;
  final void Function()? onSubmitted;

  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.maxLength,
    this.labelText,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLength: maxLength,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.grey.shade400),
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade500,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade500,
              width: 2,
            ),
          ),
        ),
        onSubmitted: (_) {
          onSubmitted!();
        },
      ),
    );
  }
}
