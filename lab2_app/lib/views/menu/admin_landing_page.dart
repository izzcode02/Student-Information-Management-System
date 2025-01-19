import 'package:flutter/material.dart';
import '../../main.dart';

class AdminLandingPage extends StatefulWidget {
  const AdminLandingPage({super.key});

  @override
  State<AdminLandingPage> createState() => _AdminLandingPageState();
}

class _AdminLandingPageState extends State<AdminLandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(
            image: const AssetImage('assets/images/uitm-logo.png'),
            height: MediaQuery.of(context).size.width * 0.3,
          ),
          ElevatedButton(
            onPressed: () async {
              setState() {}
              await auth.signOut(context);
            },
            child: const Text('Log Out'),
          )
        ],
      ),
    ));
  }
}
