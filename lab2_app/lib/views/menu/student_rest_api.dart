import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lab2_app/model/student_model.dart';

class StudentList extends StatelessWidget {
  Future<List<Student>> fetchStudents() async {
    final response =
        await Dio().get('https://www.freetestapi.com/api/v1/students');
    List<Student> students = (response.data as List)
        .map((student) => Student.fromJson(student))
        .toList();
    return students;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
      ),
      body: FutureBuilder<List<Student>>(
        future: fetchStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No students found.'));
          }

          final students = snapshot.data!;

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                leading: Image.network(student.image),
                title: Text(student.name),
                subtitle: Text('Age: ${student.age}, GPA: ${student.gpa}'),
              );
            },
          );
        },
      ),
    );
  }
}
