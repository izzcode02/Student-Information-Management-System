import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/student_profile_provider.dart';
import '../../utils/validator.dart';
import '../../widget/customButton.dart';
import '../../widget/customdropdown.dart';
import '../../widget/fieldbox.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  @override
  void initState() {
    super.initState();
    // Fetch data when the screen initializes
    Future.microtask(() =>
        Provider.of<StudentProfileProvider>(context, listen: false)
            .fetchProfileData());
  }

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Variables to track updates
  String semesterLevelUp = '';
  String courseCode = '';
  String courseName = '';
  String facultyName = '';
  String enrollmentStatusUp = '';

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<StudentProfileProvider>(context);
    final profileData = userProfileProvider.profileData;

    if (userProfileProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("User Profile")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Assign initial values if not already updated
    semesterLevelUp = semesterLevelUp.isEmpty
        ? profileData!['semester'] ?? ''
        : semesterLevelUp;
    enrollmentStatusUp = enrollmentStatusUp.isEmpty
        ? profileData!['enrollment status'] ?? ''
        : enrollmentStatusUp;
    courseCode =
        courseCode.isEmpty ? profileData!['course code'] ?? '' : courseCode;
    courseName =
        courseName.isEmpty ? profileData!['course name'] ?? '' : courseName;
    facultyName =
        facultyName.isEmpty ? profileData!['faculty name'] ?? '' : facultyName;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 238, 240),
      appBar: AppBar(
        title: const Text("Update Profile"),
      ),
      body: profileData != null
          ? Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(
                        'Academic Information',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      child: Text(
                        'Choose Semester Level',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: CustomDropdownFormField(
                        value: semesterLevelUp,
                        items: const ['1', '2', '3', '4', '5', '6', '7'],
                        onChanged: (value) {
                          setState(() {
                            semesterLevelUp = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    FieldBox(
                      keyboardType: TextInputType.emailAddress,
                      validator: Validator.validateText,
                      label: 'Update Your Course Code',
                      initial: courseCode,
                      onChanged: (value) {
                        setState(() {
                          courseCode = value;
                        });
                      },
                    ),
                    FieldBox(
                      keyboardType: TextInputType.emailAddress,
                      validator: Validator.validateText,
                      label: 'Update Your Course Name',
                      initial: courseName,
                      onChanged: (value) {
                        setState(() {
                          courseName = value;
                        });
                      },
                    ),
                    FieldBox(
                      keyboardType: TextInputType.text,
                      validator: Validator.validateText,
                      label: 'Update Your Faculty Name',
                      initial: facultyName,
                      onChanged: (value) {
                        setState(() {
                          facultyName = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Choose Enrollment Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: CustomDropdownFormField(
                        value: enrollmentStatusUp,
                        items: const ['Full-Time', 'Part-Time'],
                        onChanged: (value) {
                          setState(() {
                            enrollmentStatusUp = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    SubmitButton(
                      onPressed: _isLoading ? null : _update,
                      text: _isLoading ? 'Loading...' : 'Submit',
                      color: const Color(0xFF20237D),
                    ),
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _update() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userProfileProvider =
            Provider.of<StudentProfileProvider>(context, listen: false);

        await userProfileProvider.updateProfileData(
          semester: semesterLevelUp,
          courseCode: courseCode,
          courseName: courseName,
          facultyName: facultyName,
          enrollmentStatus: enrollmentStatusUp,
        );

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Profile updated successfully. Please return to the profile page.',
          ),
        ));
      } catch (error) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error updating profile: ${error.toString()}'),
        ));
      }
    }
  }
}
