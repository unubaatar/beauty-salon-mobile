import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {

    Future<void> _getUserIdFromSecureStorage() async {
    String? userId = await _secureStorage.read(key: 'userId'); 
    
    if (userId != null) {
      setState(() {
        _userId = userId; 
      });
    } else {
      setState(() {
        _userId = "User ID not found"; 
      });
    }
  }

   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String _userId = ""; 

  @override
  void initState() {
    super.initState();
    _getUserIdFromSecureStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_userId);
  }
} 