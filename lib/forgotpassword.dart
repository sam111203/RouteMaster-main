import 'package:authentication/uihelper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  forgotpassword(String email) async {
    if (email == "") {
      return UiHelper.CustomAlertBox(
          context, "Enter an email to reset password");
    } else {
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Forgot Password"),
          centerTitle: true,
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          UiHelper.CustomTextField(emailController, "Email", Icons.mail, false),
          SizedBox(height: 20),
          UiHelper.CustomButton(() {
            forgotpassword(emailController.text.toString());
          }, "Reset Password")
        ]));
  }
}
