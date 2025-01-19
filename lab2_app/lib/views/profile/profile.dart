import 'package:flutter/material.dart';
import 'package:lab2_app/controller/register_service.dart';
import 'package:lab2_app/views/profile/update_profile.dart';
import 'package:lab2_app/views/profile/viewprofile.dart';
import 'package:lab2_app/widget/largelisttile.dart';

import '../../main.dart';
import '../../widget/yes_no_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool delete = false;

  RegisterService auth = RegisterService();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Page')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: const AssetImage('assets/images/uitm-logo.png'),
              height: MediaQuery.of(context).size.width * 0.3,
            ),
            const SizedBox(height: 20),
            LargeListTile(
              title: const Text('View Profile'),
              subtitle: const Text('View user profile information'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ViewProfile()));
              },
            ),
            LargeListTile(
              title: const Text('Update Profile'),
              subtitle: const Text('Update user profile information'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UpdateProfile()));
              },
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Danger Zone',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    LargeListTile(
                      title: const Text('Delete Profile'),
                      titleColor: Colors.red,
                      subtitle:
                          const Text('Delete your profile account and data'),
                      backgroundColor: const Color.fromARGB(255, 230, 194, 191),
                      onTap: () async {
                        final continueDelete = await showYesNoDialog(
                          context: context,
                          title: 'DELETE?',
                          message:
                              'Are you sure you want to DELETE the data, this can be undone?',
                        );
                        if (continueDelete == true) {
                          await auth.deleteUser();
                        } else {
                          return;
                        }

                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
