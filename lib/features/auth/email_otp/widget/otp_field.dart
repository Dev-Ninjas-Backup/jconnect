import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OTPfield extends StatelessWidget {
  const OTPfield({super.key, required this.otpControllers});

  final List<TextEditingController> otpControllers;

  @override
  Widget build(BuildContext context) {
    return Pinput(
      controller: otpControllers.isNotEmpty
          ? otpControllers[0]
          : TextEditingController(),
      length: 6,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      showCursor: true,
      defaultPinTheme: PinTheme(
        width: 50,
        height: 50,
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      focusedPinTheme: PinTheme(
        width: 50,
        height: 50,
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      submittedPinTheme: PinTheme(
        width: 50,
        height: 50,
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }
}
