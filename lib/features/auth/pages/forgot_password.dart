import 'package:flutter/material.dart';
import 'package:fuel_tracker/features/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class ForgotPassword extends GetView<AuthController> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
    appBar: AppBar(title: Text('ForgotPassword')),

    body: SafeArea(
      child: Text('ForgotPasswordController'))
    );
  }
}