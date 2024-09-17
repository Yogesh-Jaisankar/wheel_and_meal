import 'package:flutter/material.dart';

class Mail extends StatefulWidget {
  const Mail({super.key});

  @override
  State<Mail> createState() => _MailState();
}

class _MailState extends State<Mail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "M A I L ",
          style: TextStyle(
              fontSize: 30, fontFamily: "Raleway", fontWeight: FontWeight.bold),
        ),
        // actions: [
        //   Lottie.asset("assets/userlogo.json", fit: BoxFit.cover),
        // ],
      ),
    );
  }
}
