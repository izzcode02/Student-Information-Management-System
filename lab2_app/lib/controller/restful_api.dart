// lib/services/api_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:lab2_app/model/customer.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://localhost:8000/api/customers';

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<List<Customer>> getCustomers() async {
    final response = await _dio.get('/');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];
      return data.map((customer) => Customer.fromJson(customer)).toList();
    } else {
      throw Exception('Failed to load customers');
    }
  }

  Future<Customer> getCustomer(int id) async {
    final response = await _dio.get('/$id');

    if (response.statusCode == 200) {
      return Customer.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to load customer');
    }
  }

  Future<Customer> createCustomer(Customer customer) async {
    final response = await _dio.post(
      '/',
      data: customer.toJson(),
    );

    if (response.statusCode == 201) {
      return Customer.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to create customer');
    }
  }

  Future<Customer> updateCustomer(int id, Customer customer) async {
    final response = await _dio.put(
      '/$id',
      data: customer.toJson(),
    );

    if (response.statusCode == 200) {
      return Customer.fromJson(response.data['data']);
    } else {
      throw Exception('Failed to update customer');
    }
  }

  Future<void> deleteCustomer(int id) async {
    final response = await _dio.delete('/$id');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete customer');
    }
  }
}
