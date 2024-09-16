import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save user details!')),
        );
      }
    }

    await db.close();
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
      appBar: AppBar(title: Text('Enter Your Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: "First Name"),
            ),
            TextFormField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: "Last Name"),
            ),
            TextFormField(
              controller: phoneController,
              enabled: false, // Phone number is not editable
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: selectedDate == null
                        ? "Date of Birth"
                        : DateFormat('yyyy-MM-dd').format(selectedDate!),
                  ),
                ),
              ),
            ),
            TextFormField(
              controller: ageController,
              enabled: false, // Age is auto-calculated
              decoration: InputDecoration(labelText: "Age"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await storeUserData();
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
