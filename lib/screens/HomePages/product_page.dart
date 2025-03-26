import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../models/productCategory.dart';
import '../../models/product.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _selectedIndex = 0;
  String selectedCategoryId = "";
  bool loading = true;

  List<ProductCategory> _categories = [];
  List<Product> _products = [];

  Future fetchCategories() async {
    try {
      final url = Uri.parse(
        'http://10.0.2.2:4004/api/v1/productCategories/all',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _categories =
              (jsonData['rows'] as List)
                  .map((eachCategory) => ProductCategory.fromJson(eachCategory))
                  .toList();
          selectedCategoryId = _categories[0].id;
        });
      } else {
        print("jiijii");
      }
      await fetchProducts();
    } catch (err) {
      print(err);
    }
  }

  Future fetchProducts() async {
    try {
      setState(() {
        loading = true;
      });
      final url = Uri.parse(
        'http://10.0.2.2:4004/api/v1/products/getByCategory',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'category': selectedCategoryId}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _products =
              (jsonData['rows'] as List)
                  .map((eachProduct) => Product.fromJson(eachProduct))
                  .toList();
        });
      } else {
        print("jiijii");
      }
      setState(() {
        loading = false;
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        children: [
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 10.0,
                children:
                    _categories.map((category) {
                      int index = _categories.indexOf(category);
                      return ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _selectedIndex = index;
                            selectedCategoryId = category.id;
                          });
                          await fetchProducts();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(120, 40),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          backgroundColor:
                              _selectedIndex == index
                                  ? Colors.pink
                                  : Colors.white,
                          side: BorderSide(color: Colors.pink, width: 2.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(
                              category.image,
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 6),
                            Text(
                              category.title,
                              style: TextStyle(
                                color:
                                    _selectedIndex == index
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          SizedBox(height: 8),
          loading
              ? Container(
                height: 600,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.pink),
                ),
              )
              : Expanded(
                child: ListView(
                  children: [
                    GridView.count(
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children:
                          _products.map((product) {
                            return GestureDetector(
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Color.fromARGB(255, 223, 221, 221),
                                    width: 2,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      children: [
                                        SizedBox(height: 16),
                                        Image.network(
                                          product.images[0],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                            12,
                                            0,
                                            12,
                                            0,
                                          ),
                                          child: Text(
                                            '${product.name}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                            8,
                                            4,
                                            8,
                                            0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                NumberFormat.currency(
                                                  locale: 'en_US',
                                                  symbol: '\₮ ',
                                                ).format(product.price),
                                                style: TextStyle(
                                                  decoration:
                                                      product.sellPrice != null
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : TextDecoration.none,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      product.sellPrice != null
                                                          ? const Color.fromARGB(
                                                            255,
                                                            153,
                                                            149,
                                                            149,
                                                          )
                                                          : Colors.black,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                product.sellPrice != null
                                                    ? NumberFormat.currency(
                                                      locale: 'en_US',
                                                      symbol: '\₮ ',
                                                    ).format(product.sellPrice)
                                                    : '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (product.sellPrice != null &&
                                        product.sellPrice! > 0)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Chip(
                                          padding: EdgeInsets.all(2),
                                          label: Text(
                                           '-${(100 - (product.sellPrice! / product.price) * 100).ceil()}%',
                                            style: TextStyle(fontSize: 11 , fontWeight: FontWeight.bold),
                                          ),
                                          visualDensity: VisualDensity(
                                            horizontal: 0.0,
                                            vertical: -4,
                                          ),
                                          backgroundColor: Colors.pink,
                                          labelStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                print('move');
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
