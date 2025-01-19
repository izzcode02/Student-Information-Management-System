import 'package:flutter/material.dart';
import '../controller/register_service.dart';
import '../utils/validator.dart';
import '../widget/customButton.dart';
import '../widget/customdropdown.dart';
import '../widget/fieldbox.dart';
import '../widget/paginatecounter.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isRegistrationSuccessful = false;
  bool _isLoading = false;

  //Controller form1
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String role = 'Student';

  //Controller form2
  final courseNameController = TextEditingController();
  final courseCodeController = TextEditingController();
  final facultyController = TextEditingController();
  String semesterLevel = '1';
  String enrollmentStatus = 'Full-Time';

  int activeIndex = 0;
  int totalIndex = 2;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE6E6FA),
        appBar: AppBar(
          title: const Text('Registration'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              if (activeIndex > 0) {
                setState(() {
                  activeIndex--;
                });
              } else if (activeIndex == 2) {
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Image(
                      image: const AssetImage('assets/images/uitm-logo.png'),
                      height: MediaQuery.of(context).size.width * 0.3,
                    ),
                  ),
                ),
                _isRegistrationSuccessful
                    ? _buildRegistrationSuccess()
                    : _buildRegistrator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrator() {
    switch (activeIndex) {
      case 0:
        return _buildRegistrationForm1();
      case 1:
        return _buildRegistrationForm2();
      default:
        return _buildRegistrationForm1();
    }
  }

  Widget _buildRegistrationForm1() {
    return Column(
      children: [
        FieldBox(
          controller: fullnameController,
          keyboardType: TextInputType.text,
          validator: Validator.validateText,
          label: "Enter your full name",
          onChanged: (value) {},
        ),
        FieldBox(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          validator: Validator.validateEmailAddress,
          label: 'Enter your email address',
          onChanged: (value) {},
        ),
        FieldBox(
          controller: passwordController,
          keyboardType: TextInputType.text,
          validator: Validator.validatePassword,
          label: 'Enter your password',
          obscureText: true,
          onChanged: (value) {},
        ),
        FieldBox(
          controller: confirmPasswordController,
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value != passwordController.text) {
              return 'Password did not match';
            }
            return null;
          },
          obscureText: true,
          label: 'Confirm Password',
          onChanged: (value) {},
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose role for registration',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: CustomDropdownFormField(
            value: role,
            items: const [
              'Student',
              'Staff',
            ],
            onChanged: (value) {
              setState(() {
                role = value;
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        SubmitButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              // next
              setState(() {
                activeIndex++;
              });
              print(activeIndex);
            }
          },
          text: 'Next',
          color: const Color(0xFF20237D),
        ),
        PaginateCounter(counter: totalIndex, currentPage: activeIndex),
      ],
    );
  }

  Widget _buildRegistrationForm2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Academic information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose semester level',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: CustomDropdownFormField(
            value: semesterLevel,
            items: const ['1', '2', '3', '4', '5', '6', '7'],
            onChanged: (value) {
              setState(() {
                semesterLevel = value;
              });
            },
          ),
        ),
        FieldBox(
          controller: courseCodeController,
          keyboardType: TextInputType.emailAddress,
          validator: Validator.validateText,
          label: 'Enter your course code',
          onChanged: (value) {},
        ),
        FieldBox(
          controller: courseNameController,
          keyboardType: TextInputType.emailAddress,
          validator: Validator.validateText,
          label: 'Enter your course name',
          onChanged: (value) {},
        ),
        FieldBox(
          controller: facultyController,
          keyboardType: TextInputType.text,
          validator: Validator.validateText,
          label: 'Enter your faculty name',
          onChanged: (value) {},
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose enrollment status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
          child: CustomDropdownFormField(
            value: enrollmentStatus,
            items: const [
              'Full-Time',
              'Part-Time',
            ],
            onChanged: (value) {
              setState(() {
                enrollmentStatus = value;
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        SubmitButton(
          onPressed: _isLoading ? null : _register,
          text: _isLoading ? 'Loading...' : 'Submit',
          color: const Color(0xFF20237D),
        ),
        PaginateCounter(counter: totalIndex, currentPage: activeIndex),
      ],
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final registerService = RegisterService();

        // Attempt to register the user with provided form data
        bool isSuccess = await registerService.registerStudent(
          fullnameController.text,
          emailController.text,
          passwordController.text,
          role,
          courseNameController.text,
          courseCodeController.text,
          facultyController.text,
          semesterLevel,
          enrollmentStatus,
          context,
        );

        setState(() {
          _isLoading = false;
          _isRegistrationSuccessful = isSuccess; // Update based on success
        });

        if (isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'Registration has succeeded, please return to the login page',
            ),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'Registration failed. Please try again.',
            ),
          ));
        }
      } catch (error) {
        // Handle unexpected errors
        setState(() {
          _isLoading = false;
          _isRegistrationSuccessful = false; // Registration failed
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'An error occurred during registration: ${error.toString()}',
          ),
        ));
      }
    }
  }

  Widget _buildRegistrationSuccess() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('Congratulation, you successfully register!'),
        const SizedBox(height: 20),
        SubmitButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: 'Back to Login',
            color: Colors.grey),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    courseNameController.dispose();
    courseCodeController.dispose();
    facultyController.dispose();
    super.dispose();
  }
}
