import 'package:flutter/material.dart';
import "./HomePages/home_page.dart";
import "./HomePages/product_page.dart";
import "./HomePages/services_page.dart";
import "./HomePages/account_page.dart";

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool hasToken = false;

  String name = '';
  String avatar = '';

  final List<Widget> _pages = [
    const HomePage(),
    const ServicesPage(),
    const ProductPage(),
    const AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    checkToken();
  }

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  void checkToken() async {
    try {
      String? token = await _secureStorage.read(key: 'token');
      if (token == null) {
        print("No token found in secure storage");
        setState(() {
          hasToken = false;
        });
        return;
      }
      try {
        final jwt = JWT.decode(token);
        final expiration = jwt.payload['exp'];
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (expiration == null) {
          print("Token does not have an expiration time.");
          setState(() {
            hasToken = false;
          });
          return;
        }
        if (expiration < now) {
          print("Token has expired");
          await _secureStorage.deleteAll();
          setState(() {
            hasToken = false;
          });
          return;
        } else {
          print("Token is valid");
          setState(() async {
            hasToken = true;
            name = (await _secureStorage.read(key: 'name'))!;
            avatar = (await _secureStorage.read(key: 'avatar'))!;
          });
        }
      } catch (e) {
        print("Error decoding token: $e");
      }
    } catch (err) {
      print("Error reading token from storage: $err");
    }
  }

  @override
  void initState() {
    super.initState();
    checkToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            hasToken
                ? Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Сайн уу ? $name',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ClipOval(
                            child: Image.network(
                              avatar,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                : Center(child: Text('Гоо сайхны салон')),
        backgroundColor: Colors.white,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Нүүр',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services),
            label: 'Үйлчилгээ',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.shop_outlined),
            activeIcon: Icon(Icons.shop),
            label: 'Бүтээгдэхүүн',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: 'Аккаунт',
          ),
        ],
      ),
    );
  }
}
