import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:otpless_flutter/otpless_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'UserDetails.dart';
import 'home.dart'; // Import your HomePage here

class OtpInputPage extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;
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
  bool _isLoading = false;

  Future<bool> checkIfUserExists(String phoneNumber) async {
    var db = await mongo.Db.create(
        "mongodb+srv://yogesh:7806@cluster0.4lglk.mongodb.net/Users?retryWrites=true&w=majority&appName=Cluster0");
    await db.open();
    var collection = db.collection('users');

    var existingUser = await collection.findOne({"_id": phoneNumber});
    await db.close();

    return existingUser != null;
  }

  void onOtpVerification(dynamic result) async {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (result != null && result['statusCode'] == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // Check if the phone number exists in the database
      bool userExists = await checkIfUserExists(widget.phoneNumber);

      if (!mounted) return;

      if (userExists) {
        // If the user exists, navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(), // Navigate to the home page
          ),
        );
      } else {
        // If the user doesn't exist, navigate to UserDetailsPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailsPage(
              phoneNumber: widget.phoneNumber, // Pass the phone number
            ),
          ),
        );
      }
    } else {
      debugPrint("OTP verification failed: $result");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP verification failed. Please try again.')),
      );
    }
  }

  Future<void> verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> arg = {
        "phone": widget.phoneNumber,
        "countryCode": widget.countryCode,
        "otp": otpController.text,
      };
      _otplessFlutterPlugin.startHeadless(onOtpVerification, arg);
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
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
                        child: Lottie.asset("assets/pin1.json"),
                      ),
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
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black87)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: otpController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              focusColor: Colors.black87,
                              hintText: "Enter Your OTP",
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the OTP';
                              }
                              if (value.length != 6) {
                                return 'OTP must be 6 digits';
                              }
                              return null;
                            },
                          ),
                        ),
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Lottie.asset("assets/otp.json", height: 100, width: 100),
              ),
            ),
        ],
      ),
    );
  }
}
