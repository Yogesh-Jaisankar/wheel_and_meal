import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:toastification/toastification.dart';
import 'package:wheel_and_meal/Screens/home.dart';

class UserDetailsPage extends StatefulWidget {
  final String phoneNumber;

  const UserDetailsPage({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  DateTime? selectedDate;

  bool isLoading = false; // To track the loading state

  String generateUserId() {
    var random = Random();
    return (10000000 + random.nextInt(90000000)).toString();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> storeUserData() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    var db = await mongo.Db.create(
        "mongodb+srv://wm:7806@wm.4lglk.mongodb.net/Users?retryWrites=true&w=majority&appName=wm");
    await db.open();
    var collection = db.collection('users');

    var existingUser = await collection.findOne({"_id": widget.phoneNumber});

    if (existingUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User with this phone number already exists!')),
      );
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    } else {
      var userData = {
        "_id": widget.phoneNumber,
        "name": nameController.text,
        "last_name": lastNameController.text,
        "phone": widget.phoneNumber,
        "dob": selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
            : null,
        "createdAt": DateTime.now().toUtc(),
      };

      var result = await collection.insertOne(userData);

      setState(() {
        isLoading = false; // Hide loading indicator
      });

      if (result.isSuccess) {
        toastification.show(
          alignment: Alignment.bottomCenter,
          context: context,
          title: Text('User details saved successfully!'),
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          showProgressBar: false,
          autoCloseDuration: const Duration(seconds: 2),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false,
        );

        toastification.show(
          alignment: Alignment.bottomCenter,
          context: context,
          title: Text("Welcome, ${nameController.text}"),
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          showProgressBar: false,
          autoCloseDuration: const Duration(seconds: 2),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save user details!')),
        );
      }
    }

    await db.close();
  }

  bool validateInputs() {
    if (nameController.text.isEmpty) {
      toastification.show(
        alignment: Alignment.topLeft,
        context: context,
        title: Text('Please enter your First name.'),
        type: ToastificationType.warning,
        style: ToastificationStyle.flatColored,
        showProgressBar: false,
        autoCloseDuration: const Duration(seconds: 2),
      );
      return false;
    }
    if (lastNameController.text.isEmpty) {
      toastification.show(
        alignment: Alignment.topLeft,
        context: context,
        title: Text('Please enter your Last name.'),
        type: ToastificationType.warning,
        style: ToastificationStyle.flatColored,
        showProgressBar: false,
        autoCloseDuration: const Duration(seconds: 2),
      );
      return false;
    }
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select your date of birth.')),
      );
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    phoneController.text = widget.phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter Your Details",
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Raleway",
                          fontSize: 40),
                    ),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black87),
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                controller: nameController,
                                cursorColor: Colors.black87,
                                decoration: InputDecoration(
                                    hintStyle: TextStyle(color: Colors.black87),
                                    hintText: "First Name",
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                        ),
                        Divider(color: Colors.black87),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black87),
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                controller: lastNameController,
                                cursorColor: Colors.black87,
                                decoration: InputDecoration(
                                    hintStyle: TextStyle(color: Colors.black87),
                                    hintText: "Last Name",
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black87),
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                              decoration: InputDecoration(
                                labelStyle: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                                border: InputBorder.none,
                                labelText: selectedDate == null
                                    ? "Date of Birth"
                                    : DateFormat('yyyy-MM-dd')
                                        .format(selectedDate!),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          if (validateInputs()) {
                            await storeUserData();
                          }
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 50,
                            width: 150,
                            decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: Text(
                                "Continue",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
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
          if (isLoading)
            Center(
              child: Lottie.asset(
                'assets/otp.json', // Path to your Lottie file
                width: 200,
                height: 200,
              ),
            ),
        ],
      ),
    );
  }
}
