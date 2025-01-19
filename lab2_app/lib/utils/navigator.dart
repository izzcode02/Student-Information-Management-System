import 'package:flutter/material.dart';

class toNavigate {
  static void goToStaff(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/users/staff");
  }

  static void gotoAdmin(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/users/admin");
  }

  static void gotoStudent(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/users/student");
  }

  static void gotoLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/login");
  }
}
