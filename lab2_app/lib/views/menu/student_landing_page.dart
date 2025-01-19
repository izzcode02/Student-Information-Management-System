import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lab2_app/model/customer.dart';
import 'package:lab2_app/views/menu/customers.dart';
import 'package:lab2_app/views/menu/message.dart';
import 'package:lab2_app/views/menu/student_rest_api.dart';
import 'package:lab2_app/views/menu/tools/tool_main.dart';
import 'package:lab2_app/views/profile/profile.dart';
import 'package:lab2_app/widget/yes_no_dialog.dart';

import '../../main.dart';
import '../../widget/balancedgridmenu.dart';

class StudentLandingPage extends StatefulWidget {
  const StudentLandingPage({super.key});

  @override
  State<StudentLandingPage> createState() => _StudentLandingPageState();
}

class _StudentLandingPageState extends State<StudentLandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 245, 236, 246),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Welcome {Username},",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const Gap(10),
                const Text(
                  "Student Information Management System",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
                Gap(25),
                Image(
                  image: const AssetImage('assets/images/uitm-logo.png'),
                  height: MediaQuery.of(context).size.width * 0.3,
                ),
                BalancedGridView(columnCount: 2, children: [
                  MenuCardSmallTile(
                    imageLink: 'assets/icons/profile.png',
                    label: 'Profile',
                    nextScreen: (context) => const ProfilePage(),
                  ),
                  MenuCardSmallTile(
                    imageLink: 'assets/icons/message.png',
                    label: 'Message',
                    nextScreen: (context) => const MessageBoxPage(),
                  ),
                  MenuCardSmallTile(
                    imageLink: 'assets/icons/settings.png',
                    label: 'Tools',
                    nextScreen: (context) => const ToolMain(),
                  ),
                  MenuCardSmallTile(
                    imageLink: 'assets/icons/profile.png',
                    label: 'Student List API',
                    nextScreen: (context) => StudentList(),
                  ),
                  MenuCardSmallTile(
                    imageLink: 'assets/icons/profile.png',
                    label: 'Books List RESTFUL API',
                    nextScreen: (context) => CustomerList(),
                  ),
                  MenuCardSmallTile(
                    imageLink: 'assets/icons/logout.png',
                    label: 'Logout',
                    nextScreen: (context) => Container(),
                    logout: true,
                  ),
                ]),
              ],
            ),
          ),
        ));
  }
}

class MenuCardSmallTile extends StatelessWidget {
  const MenuCardSmallTile({
    super.key,
    required this.imageLink,
    required this.label,
    required this.nextScreen,
    this.logout = false,
    this.backgroundColor = Colors.transparent,
  });

  final String imageLink;
  final String label;
  final WidgetBuilder nextScreen;
  final Color? backgroundColor;
  final bool? logout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: () async {
          if (logout == true) {
            final continueLogout = await showYesNoDialog(
              context: context,
              title: 'Log out',
              message: 'Are you sure you want to logout?',
            );
            if (continueLogout == true) {
              await auth.signOut(context);
            }
          } else {
            Navigator.push(context, MaterialPageRoute(builder: nextScreen));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage(imageLink),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: textTheme.labelMedium!.copyWith(
                  color: Colors.blue[900],
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
