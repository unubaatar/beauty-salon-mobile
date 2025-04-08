import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../Booking/timeReserveList.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String? customerId;
  bool loading = true;

  void checkToken() async {
    try {
      String? token = await _secureStorage.read(key: 'token');
      if (token == null) {
        print("No token found in secure storage");
        return;
      }
      try {
        final jwt = JWT.decode(token);
        final expiration = jwt.payload['exp'];
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (expiration == null) {
          print("Token does not have an expiration time.");
          return;
        }
        if (expiration < now) {
          print("Token has expired");
          await _secureStorage.deleteAll();
          return;
        } else {
          print("Token is valid");
        }
      } catch (e) {
        print("Error decoding token: $e");
      }
    } catch (err) {
      print("Error reading token from storage: $err");
    }
  }

  Future<void> _saveCredentials(String customerId, String token) async {
    await _secureStorage.write(key: 'customerId', value: customerId);
    await _secureStorage.write(key: 'token', value: token);
  }

  Future login() async {
    try {
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/customers/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': _phoneController.text,
          'password': _passwordController.text,
        }),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _saveCredentials(jsonData['customer'], jsonData['token']);
        setState(() {
          customerId = jsonData['customer'];
        });
      } else {
        print("Login failed");
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  void initState() {
    super.initState();
    checkToken();
    _loadcustomerId();
  }

  void _loadcustomerId() async {
    String? storedcustomerId = await _secureStorage.read(key: 'customerId');
    setState(() {
      customerId = storedcustomerId;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blueGrey.shade50,
      child: SafeArea(
        child:
            loading
                ? Center(child: CircularProgressIndicator())
                : customerId == null
                ? _buildLoginWidget()
                : _buildAccountSettingsWidget(),
      ),
    );
  }

  Widget _buildLoginWidget() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 40.0),
                  child: Icon(
                    Icons.account_circle_rounded,
                    size: 100,
                    color: Colors.teal,
                  ),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.teal.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.teal.shade500),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // Password TextField
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.teal.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.teal.shade500),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // Login Button
                ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0,
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Account Settings widget UI
  Widget _buildAccountSettingsWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.account_circle_rounded, size: 100, color: Colors.teal),
        const SizedBox(height: 16),
        Text(
          'Welcome, User $customerId',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () async {
            await _secureStorage.deleteAll();
            setState(() {
              customerId = null;
            });
            print("Logged out successfully");
          },
          child: const Text("Logout"),
        ),
        SizedBox(height: 8),
        ElevatedButton(onPressed: () {
                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TimeReserveList()));
        }, child: Text('Захиалгууд'))
      ],
    );
  }
}
