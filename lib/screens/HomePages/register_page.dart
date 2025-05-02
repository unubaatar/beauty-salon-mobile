import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/customer.dart';

import '../HomePages/account_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();

  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    _lastNameController.addListener(_validateForm);
    _firstNameController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _rePasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      isFormValid =
          _lastNameController.text.isNotEmpty &&
          _firstNameController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _rePasswordController.text.isNotEmpty;
    });
  }

  Future registerCustomer() async {
    try {
      if (_passwordController.text != _rePasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Нууц үг таарахгүй байна.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ),
        );
        return;
      }

      final url = Uri.parse('http://10.0.2.2:4004/api/v1/customers/create');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      print("Creating customer......");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Амжилттай бүртгэл үүслээ.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Бүртгэлтэй дугаар эсвэл имэйл байна.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (err) {
      print("Error: $err");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Сүлжээний алдаа гарлаа.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Бүртгүүлэх"), backgroundColor: Colors.white),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _lastNameController,
              decoration: _inputDecoration("Овог"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _firstNameController,
              decoration: _inputDecoration("Нэр"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: _inputDecoration("Утасны дугаар"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: _inputDecoration("Мейл хаяг"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: _inputDecoration("Нууц үг"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _rePasswordController,
              obscureText: true,
              decoration: _inputDecoration("Давтан оруулна уу"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isFormValid ? registerCustomer : null,
              child: Text('Бүртгүүлэх'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 32.0,
                ),
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
