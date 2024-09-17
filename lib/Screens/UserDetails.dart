import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:toastification/toastification.dart';
import 'package:wheel_and_meal/Screens/home.dart';

class UserDetailsPage extends StatefulWidget {
  final String phoneNumber; // Passed from the OTP page

  const UserDetailsPage({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  DateTime? selectedDate; // For storing the selected DOB

  // Function to generate a random 8-digit user ID
  String generateUserId() {
    var random = Random();
    return (10000000 + random.nextInt(90000000))
        .toString(); // Generates an 8-digit ID
  }

  // Function to open the date picker for DOB selection
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
        // Calculate and display age
      });
    }
  }

  // Function to store the data in MongoDB
  Future<void> storeUserData() async {
    var db = await mongo.Db.create(
        "mongodb+srv://yogesh:7806@cluster0.4lglk.mongodb.net/Users?retryWrites=true&w=majority&appName=Cluster0");
    await db.open();
    var collection = db.collection('users');

    // Check if the phone number already exists
    var existingUser = await collection.findOne({"_id": widget.phoneNumber});

    if (existingUser != null) {
      // If the phone number already exists, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User with this phone number already exists!')),
      );
    } else {
      // If the phone number does not exist, insert the new user data
      var userData = {
        "_id": widget.phoneNumber, // Use the phone number as the unique _id
        "name": nameController.text,
        "last_name": lastNameController.text,
        "phone": widget.phoneNumber,
        "dob": selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
            : null,
        "createdAt": DateTime.now().toUtc(), // Store the current timestamp
      };

      // Insert the document and capture the result
      var result = await collection.insertOne(userData);

      // Check if the insert was successful
      if (result.isSuccess) {
        toastification.show(
          alignment: Alignment.bottomCenter,
          context: context, // optional if you use ToastificationWrapper
          title: Text('User details saved successfully!'),
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          showProgressBar: false,
          autoCloseDuration: const Duration(seconds: 2),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => Home()), // Replace with your target page
          (Route<dynamic> route) => false, // This clears all previous routes
        );

        toastification.show(
          alignment: Alignment.bottomCenter,
          context: context, // optional if you use ToastificationWrapper
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
        context: context, // optional if you use ToastificationWrapper
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
        context: context, // optional if you use ToastificationWrapper
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
    phoneController.text = widget.phoneNumber; // Pre-fill the phone number
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
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
                    Divider(
                      color: Colors.black87,
                    ),
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
    );
  }
}
