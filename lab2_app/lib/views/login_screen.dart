import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lab2_app/widget/customButton.dart';

import '../main.dart';
import '../utils/validator.dart';
import '../widget/fieldbox.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? email;
  String? password;

  bool _isLoading = false;
  bool isStudent = true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFE6E6FA),
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.4,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
            topLeft: Radius.zero,
            topRight: Radius.zero,
          ),
          child: Container(
            color: const Color.fromARGB(255, 221, 199, 237),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  image: const AssetImage('assets/images/uitm-logo.png'),
                  height: MediaQuery.of(context).size.width * 0.3,
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  'Student Information \nManagement System (SIMS)',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.w900,
                    color: const Color.fromARGB(255, 255, 251, 251),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Login Authentication',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              FieldBox(
                // key: UniqueKey(),
                isSmallSized: true,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validator.validateEmailAddress,
                label: 'Enter your email address',
                onChanged: (value) {
                  _emailController.text = value;
                },
              ),
              FieldBox(
                // key: UniqueKey(),
                isSmallSized: true,
                keyboardType: TextInputType.text,
                controller: _passwordController,
                validator: Validator.validatePassword,
                label: 'Enter your password',
                obscureText: true,
                onChanged: (value) {
                  _passwordController.text = value;
                },
              ),
              const SizedBox(height: 40),
              //Button
              ElevatedButton(
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(const Size(300, 50)),
                  padding: WidgetStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(vertical: 0)),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(const Color(0xFF20237D)),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFF20237D)),
                    ),
                  ),
                ),
                //onPressed: login,
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          email = _emailController.text;
                          password = _passwordController.text;
                        });

                        if (_emailController.text == " " ||
                            _passwordController.text == " ") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please fullfil the form above first.'),
                            ),
                          );
                        } else {
                          await _login(email, password, context);
                        }

                        //check if it return data or not
                        print('$email + $password ');
                      },
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: 0.4,
                            child: const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const Text(
                            'Loading',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        "Log in".toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              SubmitButton(
                onPressed: () async {
                  final user = await auth.signInWithGoogle(context);
                  if (user != null) {
                    print("Signed in as: ${user.displayName}");
                  } else {
                    print("Sign-in canceled");
                  }
                },
                text: 'Log In with Google'.toUpperCase(),
                color: const Color.fromARGB(255, 255, 147, 59),
                icon: const Icon(
                  Ionicons.logo_google,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              const NextButton(
                valueColor: 0xFF000000,
                nameButton: 'Register',
                routeName: '/register',
              ),
            ],
          ),
        ),
      ),
    );
  }

  _login(String? email, String? password, BuildContext context) async {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
    } else {
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      await auth.signIn(email!, password!, context);
      auth.currentUserScreen(context);
      // await navigateToLandingPage(password!);

      if (!mounted) return;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // navigateToLandingPage(String loginInput) {
  //   // Check if the login input is a number
  //   if (RegExp(r'^\d+$').hasMatch(loginInput)) {
  //     int loginNumber = int.parse(loginInput);
  //     // Check if the number is within the specified range
  //     if (loginNumber >= 2018000000 && loginNumber <= 2024999999) {
  //       print("Navigating to Student Landing Page");
  //       // Navigate to Student Landing Page
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const StudentLandingPage(),
  //         ),
  //       );
  //     } else {
  //       print("Invalid student number range");
  //     }
  //   }
  //   // Check if the login input is 'root'
  //   else if (loginInput == 'root') {
  //     print("Navigating to Admin Landing Page");

  //     // Navigate to Admin Landing Page
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const AdminLandingPage(),
  //       ),
  //     );
  //   }
  //   // Check if the login input is alphabetic
  //   else if (RegExp(r'^[a-zA-Z]+$').hasMatch(loginInput)) {
  //     print("Navigating to Staff Landing Page");

  //     // Navigate to Staff Landing Page
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const StaffLandingPage(),
  //       ),
  //     );
  //     // Navigator.pushNamed(context, '/staffLandingPage');
  //   }

  //   // If none of the above, it's an invalid input
  //   else {
  //     print(loginInput.toString());
  //     print("Invalid login input");
  //   }
  // }
}
