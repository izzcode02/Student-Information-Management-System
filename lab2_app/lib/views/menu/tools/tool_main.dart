import 'package:flutter/material.dart';
import 'package:lab2_app/views/menu/tools/accelerometer.dart';
import 'package:lab2_app/views/menu/tools/bluetooth.dart';
import 'package:lab2_app/views/menu/tools/camera_and_qr.dart';
import 'package:lab2_app/views/menu/tools/gps.dart';
import 'package:lab2_app/views/menu/tools/microphone.dart';

import '../../../widget/balancedgridmenu.dart';
import '../student_landing_page.dart';

class ToolMain extends StatefulWidget {
  const ToolMain({super.key});

  @override
  State<ToolMain> createState() => _ToolMainState();
}

class _ToolMainState extends State<ToolMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(
            image: const AssetImage('assets/images/uitm-logo.png'),
            height: MediaQuery.of(context).size.width * 0.3,
          ),
          BalancedGridView(columnCount: 2, children: [
            MenuCardSmallTile(
              imageLink: 'assets/icons/settings.png',
              label: 'Accelerometer',
              nextScreen: (context) => const AccelerometerExample(),
            ),
            MenuCardSmallTile(
              imageLink: 'assets/icons/settings.png',
              label: 'Camera and QR',
              nextScreen: (context) => const CameraAndQr(),
            ),
            MenuCardSmallTile(
              imageLink: 'assets/icons/settings.png',
              label: 'GPS',
              nextScreen: (context) => GPS(),
            ),
            MenuCardSmallTile(
              imageLink: 'assets/icons/settings.png',
              label: 'Microphone',
              nextScreen: (context) => Microphone(),
            ),
            MenuCardSmallTile(
              imageLink: 'assets/icons/settings.png',
              label: 'Bluetooth',
              nextScreen: (context) => Bluetooth(),
            ),
          ]),
        ],
      ),
    );
  }
}
