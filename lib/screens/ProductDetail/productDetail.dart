import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/material.dart';
import 'package:test/models/productVariant.dart';

import '../../models/product.dart';

class ProductDetail extends StatefulWidget {
  final String productId;
  const ProductDetail({super.key, required this.productId});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late ProductVariant? selectedVariant = null;
  late Product product;
  bool loading = true;
  late List<bool> _selectedVariants;
  int selectedQty = 1;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

Future addItemCart() async {
  try {
    String? customerId = await _secureStorage.read(key: 'customerId');

    final chosenSellPrice = selectedVariant != null
        ? selectedVariant!.sellPrice
        : product.sellPrice;

    final url = Uri.parse('http://10.0.2.2:4004/api/v1/cartItems/create');


    final Map<String, dynamic> body = {
      'customer': customerId,
      'product': product.id,
      if(selectedVariant != null)'variant': selectedVariant?.id,
      'qty': selectedQty,
      'price': selectedVariant?.price ?? product.price,
      if (chosenSellPrice != null) 'sellPrice': chosenSellPrice,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Амжилттай үүслээ')),
      );
    } else {
      print(response.body);
      print('jiijii');
    }
  } catch (err) {
    print(err);
  }
}

  Future fetchProduct() async {
    try {
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/products/getById');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'_id': widget.productId}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          product = Product.fromJson(jsonData);
          if (product.variants.isNotEmpty) {
            _selectedVariants = List.generate(
              product.variants.length,
              (index) => false,
            );
            selectedVariant =
                (product.variants.isNotEmpty
                    ? ProductVariant(
                      id: product.variants[0].id,
                      title: product.variants[0].title,
                      price: product.variants[0].price,
                      sellPrice: product.variants[0].sellPrice,
                      images: product.variants[0].images,
                    )
                    : null);
            _selectedVariants[0] = true;
          }
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
    fetchProduct();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()),
        )
        : Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(product.name),
            backgroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.network(
                    product.images[0],
                    width: double.infinity,
                    fit: BoxFit.cover,
                    height: 400,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Chip(
                              backgroundColor: const Color.fromARGB(
                                255,
                                199,
                                44,
                                83,
                              ),
                              surfaceTintColor: const Color.fromARGB(
                                255,
                                199,
                                44,
                                83,
                              ),
                              label: Text(
                                product.category.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 0,
                              ),
                              visualDensity: const VisualDensity(
                                horizontal: -4.0,
                                vertical: -4.0,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (product.variants.isNotEmpty)
                          Container(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              spacing: 10.0,
                              children:
                                  product.variants.map((variant) {
                                    int index = product.variants.indexOf(
                                      variant,
                                    );
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(100, 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 8.0,
                                        ),
                                        backgroundColor:
                                            _selectedVariants[index]
                                                ? const Color.fromARGB(
                                                  255,
                                                  199,
                                                  44,
                                                  83,
                                                )
                                                : Colors.white,
                                        side: const BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            199,
                                            44,
                                            83,
                                          ),
                                          width: 2.0,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          for (
                                            int i = 0;
                                            i < _selectedVariants.length;
                                            i++
                                          ) {
                                            _selectedVariants[i] = i == index;
                                          }
                                          selectedVariant = variant;
                                        });
                                      },

                                      child: Text(
                                        variant.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color:
                                              _selectedVariants[index]
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text(product.description),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                            labelText: 'Тоо ширхэг',
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                          ),
                          value: selectedQty,
                          items:
                              [1, 2, 3, 4, 5].map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString()),
                                );
                              }).toList(),
                          onChanged: (int? newValue) {
                            selectedQty = newValue!;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomSheet: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            height: 80,
            child: Padding(
              padding: EdgeInsets.fromLTRB(32, 4, 32, 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        selectedVariant != null
                            ? Text(
                              NumberFormat.currency(
                                locale: 'en_US',
                                symbol: '\₮ ',
                              ).format(selectedVariant?.price),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color:
                                    selectedVariant?.sellPrice == null
                                        ? Colors.black
                                        : Colors.grey,
                                decoration:
                                    selectedVariant?.sellPrice != null
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                              ),
                            )
                            : Text(
                              NumberFormat.currency(
                                locale: 'en_US',
                                symbol: '\₮ ',
                              ).format(product.price),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color:
                                    product.sellPrice == null
                                        ? Colors.black
                                        : Colors.grey,
                                decoration:
                                    product.sellPrice != null
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                              ),
                            ),

                        selectedVariant != null
                            ? Text(
                              selectedVariant?.sellPrice != null
                                  ? NumberFormat.currency(
                                    locale: 'en_US',
                                    symbol: '\₮ ',
                                  ).format(selectedVariant?.price)
                                  : '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                            : Text(
                              product.sellPrice != null
                                  ? NumberFormat.currency(
                                    locale: 'en_US',
                                    symbol: '\₮ ',
                                  ).format(product.sellPrice)
                                  : '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                      ),
                      onPressed: () {
                        addItemCart();
                      },
                      child: Text(
                        'Сагслах',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
