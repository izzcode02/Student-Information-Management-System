// lib/models/customer.dart

class Customer {
  final int id;
  final String name;
  final String email;

  Customer({required this.id, required this.name, required this.email});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
    };
  }
}
