import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../Booking/timeReserveList.dart';
import '../Order/orderList.dart';
import '../home_screen.dart';
import '../HomePages/register_page.dart';

import '../../models/customer.dart';

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
  bool profileLoading = true;

  Customer? customer;

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
          String? storedcustomerId = await _secureStorage.read(
            key: 'customerId',
          );
          await fetchCustomerDetails(storedcustomerId);
        }
      } catch (e) {
        print("Error decoding token: $e");
      }
    } catch (err) {
      print("Error reading token from storage: $err");
    }
  }

  Future fetchCustomerDetails(storedcustomerId) async {
    try {
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/customers/getById');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'_id': storedcustomerId}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          customer = Customer.fromJson(jsonData);
        });
        print('oldloo');
      } else {
        print('jiijiii');
      }
      setState(() {
        profileLoading = false;
      });
    } catch (err) {
      print(err);
    }
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

        await _secureStorage.write(
          key: 'customerId',
          value: jsonData['customer'],
        );
        await _secureStorage.write(key: 'token', value: jsonData['token']);
        await _secureStorage.write(key: 'name', value: jsonData['name']);
        await _secureStorage.write(key: 'avatar', value: jsonData['avatar']);
        setState(() {
          customerId = jsonData['customer'];
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
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
    return loading
        ? Center(child: CircularProgressIndicator(backgroundColor: Colors.pink))
        : customerId == null
        ? Center(child: _buildLoginWidget())
        : Center(child: _buildAccountSettingsWidget());
  }

  Widget _buildLoginWidget() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Image.network(
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSIIWju1ABYrb5DTkZ8mbDcaAekrgKnjmf0CA&s",
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),

                Text(
                  'Гоо сайхны салоны систем',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 32),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: "Утас",
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Нууц үг",
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),

                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),

                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    login();
                  },
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
                  child: const Text(
                    "Нэвтрэх",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 32.0,
                    ),
                    minimumSize: Size(double.infinity, 24),
                  ),
                  child: Text('Register', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettingsWidget() {
    return profileLoading
        ? Center(child: CircularProgressIndicator(backgroundColor: Colors.pink))
        : SingleChildScrollView(
          child: Column(
            children: [
              ClipOval(
                child: Image.network(
                  customer!.avatar,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 32),

              Text(
                '${customer!.firstName} ${customer!.lastName}',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 8),

              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phone, size: 24),
                        SizedBox(width: 8),
                        Text('Утас: ', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            customer!.phone,
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.mail, size: 24),
                        SizedBox(width: 8),
                        Text('Мейл: ', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            customer!.email,
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimeReserveList(),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey, width: 1),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.punch_clock,
                                size: 40,
                                color: Colors.black,
                              ),
                              Text(
                                'Цаг товлолтууд',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => OrderList(customer: customerId),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey, width: 1),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart,
                                size: 40,
                                color: Colors.black,
                              ),
                              Text(
                                'Бүтээгдэхүүн захиалгууд',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey, width: 1),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.settings,
                                size: 40,
                                color: Colors.black,
                              ),
                              Text(
                                'Тохиргоо',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _secureStorage.deleteAll();
                        setState(() {
                          customerId = null;
                        });
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      },
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey, width: 1),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, size: 40, color: Colors.black),
                              Text(
                                'Гарах',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
  }
}
