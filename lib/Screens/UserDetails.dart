import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
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

  // Function to calculate the age from DOB
  int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
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
        ageController.text =
            calculateAge(selectedDate!).toString(); // Calculate and display age
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
        "age": ageController.text,
      };

      // Insert the document and capture the result
      var result = await collection.insertOne(userData);

      // Check if the insert was successful
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User details saved successfully!')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => Home()), // Replace with your target page
          (Route<dynamic> route) => false, // This clears all previous routes
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your first name.')),
      );
      return false;
    }
    if (lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your last name.')),
      );
      return false;
    }
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select your date of birth.')),
      );
      return false;
    }
    if (ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please calculate your age by selecting your date of birth.')),
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
              children: [
                Lottie.asset("assets/user.json", height: 200, width: 200),
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
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black87),
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black87),
                      ),
                      controller: phoneController,
                      enabled: false, // Phone number is not editable
                    ),
                  ),
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
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black87),
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      style: TextStyle(color: Colors.black87),
                      controller: ageController,
                      enabled: false, // Age is auto-calculated
                      decoration: InputDecoration(
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                          labelText: "Age",
                          border: InputBorder.none),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () async {
                      if (validateInputs()) {
                        await storeUserData();
                      }
                    },
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
                              color: Colors.white, fontWeight: FontWeight.bold),
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
