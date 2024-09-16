import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:otpless_flutter/otpless_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final _formKey = GlobalKey<FormState>();

  void onOtpVerification(dynamic result) async {
    if (result != null && result['statusCode'] == 200) {
      if (!mounted) return; // Check if widget is still mounted

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      debugPrint("OTP verification failed: $result");
      if (!mounted) return; // Ensure mounted before showing snackbar

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP verification failed. Please try again.')),
      );
    }
  }

  Future<void> verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> arg = {
        "phone": widget.phoneNumber,
        "countryCode": widget.countryCode, // Use the passed country code
        "otp": otpController.text,
      };
      _otplessFlutterPlugin.startHeadless(onOtpVerification, arg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      height: 200,
                      width: 200,
                      child: Lottie.asset("assets/pin1.json")),
                  SizedBox(height: 20),
                  Text(
                    "OTP has been sent to ",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Raleway"),
                  ),
                  Text(
                    widget.phoneNumber,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 50),
                  TextFormField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      focusColor: Colors.black87,
                      labelText: "Enter OTP",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the OTP';
                      }
                      if (value.length != 6) {
                        // Assuming a 6-digit OTP
                        return 'OTP must be 6 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: () {
                      verifyOtp();
                    },
                    child: Container(
                      height: 50,
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Text(
                          "CONFIRM",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Wrong Number?"),
                      SizedBox(width: 5),
                      Icon(
                        size: 20,
                        Icons.mode_edit_outlined,
                        weight: .5,
                        grade: .5,
                        opticalSize: .5,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
