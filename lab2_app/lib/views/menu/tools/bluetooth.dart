import 'package:flutter/material.dart';
import 'package:lab2_app/widget/customButton.dart';
import 'package:universal_ble/universal_ble.dart';

class Bluetooth extends StatefulWidget {
  const Bluetooth({super.key});

  @override
  State<Bluetooth> createState() => _BluetoothState();
}

class _BluetoothState extends State<Bluetooth> {
  AvailabilityState _availabilityState = AvailabilityState.unknown;
  bool isBluetoothOn = false;

  @override
  void initState() {
    super.initState();
    _initializeBluetoothState();

    // Listen to Bluetooth availability changes
    UniversalBle.onAvailabilityChange = (state) {
      setState(() {
        _availabilityState = state;
      });
    };
  }

  Future<void> _initializeBluetoothState() async {
    try {
      // Get the initial Bluetooth state
      final state = UniversalBle.getBluetoothAvailabilityState();
      setState(() {
        _availabilityState = state as AvailabilityState;
      });
    } catch (e) {
      print("Error initializing Bluetooth state: $e");
    }
  }

  void _toggleBluetooth() {
    if (_availabilityState == AvailabilityState.poweredOn) {
      UniversalBle.disableBluetooth();
    } else if (_availabilityState == AvailabilityState.poweredOff) {
      UniversalBle.enableBluetooth();
    }
  }

  void Scanning() {
    // Set a scan result handler
    UniversalBle.onScanResult = (bleDevice) {
      // e.g. Use BleDevice ID to connect
    };

    // Perform a scan
    // Or listen to bluetooth availability changes
    UniversalBle.onAvailabilityChange = (state) {
      if (state == AvailabilityState.poweredOn) {
        UniversalBle.startScan();
      } else {
        // Stop scanning
        UniversalBle.stopScan();
      }
    };
  }

  List<BleDevice> bluetoothDevices() {
    List<BleDevice> devices =
        UniversalBle.getSystemDevices(withServices: []) as List<BleDevice>;

    return devices;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Bluetooth is ${isBluetoothOn ? "ON" : "OFF"}",
              style: TextStyle(fontSize: 20),
            ),
            Switch(
              value: isBluetoothOn,
              onChanged: (value) {
                _toggleBluetooth();

                setState(() {
                  isBluetoothOn = value;
                });
              },
            ),
            isBluetoothOn
                ? SubmitButton(
                    onPressed: () {
                      Scanning();
                    },
                    text: 'Scan Device',
                    color: Colors.blue)
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
