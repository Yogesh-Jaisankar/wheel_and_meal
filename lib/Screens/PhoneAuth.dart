import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _otplessFlutterPlugin.initHeadless(appId);
      _otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
      debugPrint("init headless sdk is called for android");
    }
  }

  void onHeadlessResult(dynamic result) {
    debugPrint("Phone auth response: $result");
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => OtpInputPage(
          phoneNumber: phoneController.text,
          countryCode: '+91',
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
    if (Platform.isIOS && !isInitIos) {
      _otplessFlutterPlugin.initHeadless(appId);
      _otplessFlutterPlugin.setHeadlessCallback(onHeadlessResult);
      isInitIos = true;
      return;
    }
    Map<String, dynamic> arg = {
      "phone": phoneController.text,
      "countryCode": "91", // Change country code as required
    };
    _otplessFlutterPlugin.startHeadless(onHeadlessResult, arg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Authentication")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              onPressed: startPhoneAuth,
              child: const Text("Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
