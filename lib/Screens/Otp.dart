import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:otpless_flutter/otpless_flutter.dart';
import 'package:wheel_and_meal/Screens/home.dart';

class OtpInputPage extends StatefulWidget {
  final String phoneNumber;
  final String countryCode; // Added for country code
  const OtpInputPage(
      {Key? key, required this.phoneNumber, required this.countryCode})
      : super(key: key);

  @override
  _OtpInputPageState createState() => _OtpInputPageState();
}

class _OtpInputPageState extends State<OtpInputPage> {
  final TextEditingController otpController = TextEditingController();
  final _otplessFlutterPlugin = Otpless();

  void onOtpVerification(dynamic result) {
    if (result != null && result['statusCode'] == 200) {
      // Navigate to home on successful OTP verification
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
      otpController.clear(); // Clear OTP field on success
    } else {
      // Handle error case
      debugPrint("OTP verification failed: $result");
      // Optionally show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP verification failed. Please try again.')),
      );
    }
  }

  Future<void> verifyOtp() async {
    Map<String, dynamic> arg = {
      "phone": widget.phoneNumber,
      "countryCode": widget.countryCode, // Use the passed country code
      "otp": otpController.text,
    };
    _otplessFlutterPlugin.startHeadless(onOtpVerification, arg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter OTP",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: verifyOtp,
              child: const Text("Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
