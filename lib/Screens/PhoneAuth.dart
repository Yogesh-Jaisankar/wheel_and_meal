import 'dart:async';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:otpless_flutter/otpless_flutter.dart';

import 'Otp.dart';

class PhoneInputPage extends StatefulWidget {
  const PhoneInputPage({Key? key}) : super(key: key);

  @override
  _PhoneInputPageState createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends State<PhoneInputPage> {
  final TextEditingController phoneController = TextEditingController();
  final _otplessFlutterPlugin = Otpless();
  bool isInitIos = false;
  static const String appId = "H36KQYXL24MCA0LISYA9";

  String selectedCountryCode = '+91'; // Default country code
  bool isPhoneNumberValid = false;
  bool isLoading = false;
  bool isProcessing = false; // New flag for processing state

  Timer? timer; // Declare timer variable
  int currentIndex = 0; // Current index for cycling texts
  List<String> texts = [
    "Hello!!",
    "வணக்கம்!!",
    "नमस्ते!!",
    "నమస్కారం!!",
    "ഹലോ!!",
    "ನಮಸ್ಕಾರ"
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
    phoneController.addListener(() {
      setState(() {
        isPhoneNumberValid = phoneController
            .text.isNotEmpty; // Check if phone number is not empty
      });
    });
    if (Platform.isAndroid) {
      _otplessFlutterPlugin.initHeadless(appId);
      _otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
      debugPrint("init headless sdk is called for android");
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      setState(() {
        currentIndex = (currentIndex + 1) % texts.length; // Cycle through texts
      });
    });
  }

  void onHeadlessResult(dynamic result) {
    debugPrint("Phone auth response: $result");

    if (!mounted) return; // Check if widget is still mounted

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => OtpInputPage(
          phoneNumber: phoneController.text,
          countryCode: selectedCountryCode,
        ),
      ),
    );
  }

  Future<void> startHeadlessWithWhatsapp() async {
    if (Platform.isIOS && !isInitIos) {
      _otplessFlutterPlugin.initHeadless(appId);
      _otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
      isInitIos = true;
      debugPrint("init headless sdk is called for ios");
      return;
    }
    Map<String, dynamic> arg = {'channelType': "WHATSAPP"};
    _otplessFlutterPlugin.startHeadless(onHeadlessResult, arg);
  }

  Future<void> startPhoneAuth() async {
    if (isProcessing) return; // Prevent multiple clicks
    setState(() {
      isProcessing = true; // Set processing to true
      isLoading = true; // Show loading indicator immediately
    });

    // Hide the keyboard
    FocusScope.of(context).unfocus();

    try {
      Map<String, dynamic> arg = {
        "phone": phoneController.text,
        "countryCode": selectedCountryCode.replaceAll('+', ''),
      };

      await _otplessFlutterPlugin.startHeadless(onHeadlessResult, arg);
      print("Otpless headless started successfully");

      // Wait for at least 3 seconds before navigating
      await Future.delayed(Duration(seconds: 3));

      // Now navigate to OTP page
      if (isLoading) {
        setState(() {
          isLoading = false; // Stop loading animation
        });
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => OtpInputPage(
              phoneNumber: phoneController.text,
              countryCode: selectedCountryCode,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error starting phone auth: $e");
      // Optionally show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send OTP. Please try again.")),
      );
    } finally {
      setState(() {
        isProcessing = false; // Reset processing state
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset("assets/cycle.json"),
                const SizedBox(height: 30),
                Container(
                  height: 100,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      texts[currentIndex],
                      style: TextStyle(fontSize: 40, fontFamily: "Raleway"),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all()),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CountryCodePicker(
                          initialSelection: "IN",
                          onChanged: (code) {
                            setState(() {
                              selectedCountryCode = code.dialCode!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextField(
                          cursorColor: Colors.black87,
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: "Phone Number",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: "Read our ",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: "Privacy and Policy",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _loadContent('assets/privacy_policy.txt')
                                .then((content) {
                              _showDialog(
                                  context, "Privacy and Policy", content);
                            });
                          },
                      ),
                      TextSpan(
                        text: " and Tap Agree and continue to accept our ",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: "Terms and Conditions",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _loadContent('assets/tc.txt').then((content) {
                              _showDialog(
                                  context, "Terms and Conditions", content);
                            });
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),

                // Show Lottie animation if loading, otherwise show button
                isLoading
                    ? Center(
                        child: Container(
                          height: 150,
                          width: 150,
                          child: Lottie.asset('assets/pin1.json'),
                        ),
                      )
                    : GestureDetector(
                        onTap: isPhoneNumberValid && !isProcessing
                            ? () {
                                HapticFeedback.heavyImpact();
                                setState(() {
                                  isLoading = true; // Start loading animation
                                });
                                startPhoneAuth();
                              }
                            : null, // Disable if not valid or processing
                        child: Container(
                          height: 50,
                          width: 250,
                          decoration: BoxDecoration(
                            color: isPhoneNumberValid && !isProcessing
                                ? Colors.green
                                : Colors.black87,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              "AGREE & CONTINUE",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _loadContent(String path) async {
    return await rootBundle.loadString(path);
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title),
          content: SingleChildScrollView(child: Text(content)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "Close",
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        );
      },
    );
  }
}
