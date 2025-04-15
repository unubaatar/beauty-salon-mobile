import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:intl/intl.dart';
import "../Order/orderDetail.dart";

import '../../models/cartItem.dart';

class OrderCreate extends StatefulWidget {
  const OrderCreate({super.key});

  @override
  State<OrderCreate> createState() => _OrderCreateState();
}

class _OrderCreateState extends State<OrderCreate> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<CartItem> _cartItems = [];
  int cartItemCount = 0;
  int cartTotalPrice = 0;
  String orderType = "delivery";

  int currentStep = 1;

  final TextEditingController provinceController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardEndDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  Future deleteCartItem(cartItemId) async {
    try {
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/cartItems/delete');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'_id': cartItemId}),
      );
      if (response.statusCode == 200) {
        print('deleted successfully');
      } else {
        print("jiijii");
      }
    } catch (err) {
      print(err);
    }
  }

  Future updateCartItem(cartItemId, qty) async {
    try {
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/cartItems/update');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'_id': cartItemId, 'qty': qty}),
      );
      if (response.statusCode == 200) {
        print('updated');
      } else {
        print("jiijii");
      }
    } catch (err) {
      print(err);
    }
  }

  Future fetchCartItems() async {
    try {
      String? customerId = await _secureStorage.read(key: 'customerId');
      final url = Uri.parse(
        'http://10.0.2.2:4004/api/v1/cartItems/getByCustomer',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'customer': customerId}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          cartTotalPrice = 0;
          _cartItems =
              (jsonData['rows'] as List)
                  .map((eachItem) => CartItem.fromJson(eachItem))
                  .toList();
          cartItemCount = jsonData['count'];
          _cartItems.forEach((cartItem) {
            if (cartItem.variant != null) {
              cartTotalPrice +=
                  cartItem.variant!.sellPrice != null
                      ? (cartItem.variant!.sellPrice! * cartItem.qty)
                      : cartItem.variant!.price * cartItem.qty;
            } else {
              cartTotalPrice +=
                  cartItem.product.sellPrice != null
                      ? (cartItem.product.sellPrice! * cartItem.qty)
                      : cartItem.product.price * cartItem.qty;
            }
          });
        });
        print('fetched all');
      } else {
        print("jiijii");
      }
    } catch (err) {
      print(err);
    }
  }

  Future createOrder() async {
    try {
      List<String> items = [];
      _cartItems.forEach((cartItem) {
        items.add(cartItem.id);
      });
      String? customerId = await _secureStorage.read(key: 'customerId');
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/orders/create');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer': customerId,
          'items': items,
          'address': {
            'province': provinceController.text,
            'district': districtController.text,
            'section': sectionController.text,
            'address': addressController.text,
          },
          'orderType': orderType,
        }),
      );
      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return jsonData['_id'];
      } else {
        print("jiijii");
      }
    } catch (err) {
      print(err);
    }
  }

  void goBack() {
    if (currentStep == 1) {
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      setState(() {
        currentStep--;
      });
    }
  }

  void nextStep() async {
    if (currentStep == 1) {
      setState(() {
        currentStep++;
      });
    } else if (currentStep == 2) {
      setState(() {
        currentStep++;
      });
    } else if (currentStep == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Амжилттай төлөгдлөө, Захиалга үүсгэж байна. '),
          backgroundColor: Colors.green,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      String orderId = await createOrder();
      await Future.delayed(Duration(seconds: 2));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetail(orderDetailId: orderId),
        ),
      );
    }
  }

  void _updateFormState() {
    setState(() {});
    provinceController.addListener(_updateFormState);
    districtController.addListener(_updateFormState);
    sectionController.addListener(_updateFormState);
    addressController.addListener(_updateFormState);
    // cardEndDateController.addListener(_updateFormState);
    // cardNumberController.addListener(_updateFormState);
    // cardHolderController.addListener(_updateFormState);
    // cvvController.addListener(_updateFormState);
  }

  @override
  void dispose() {
    provinceController.dispose();
    districtController.dispose();
    sectionController.dispose();
    addressController.dispose();
    // cardEndDateController.dispose();
    // cardNumberController.dispose();
    // cardHolderController.dispose();
    // cvvController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchCartItems();
    _updateFormState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Захиалга үүсгэх'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: TextButton(
                onPressed: () {
                  goBack();
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(40, 40),
                  foregroundColor: Colors.pink,
                ),
                child: const Icon(Icons.backspace_outlined),
              ),
            ),
            const Expanded(flex: 1, child: const SizedBox()),
            Expanded(
              flex: 18,
              child: ElevatedButton(
                onPressed:
                    (currentStep == 2 &&
                            (provinceController.text.trim().isEmpty ||
                                districtController.text.trim().isEmpty ||
                                sectionController.text.trim().isEmpty ||
                                addressController.text.trim().isEmpty))
                        ? null
                        : () => nextStep(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 40),
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  currentStep == 3
                      ? '   ${'Төлбөр төлөх'}'
                      : '${'Үргэлжлүүлэх'}',
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child:
            currentStep == 1
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              'Таны сагс',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 16),
                            ..._cartItems.map((cartItem) {
                              return SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: Card(
                                  color: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: Color.fromARGB(255, 225, 224, 224),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            cartItem.variant != null
                                                ? cartItem.variant!.images[0]
                                                : cartItem.product.images[0],
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cartItem.product.name,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                softWrap: false,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),

                                              if (cartItem.variant?.title !=
                                                  null)
                                                Text(
                                                  cartItem.variant!.title,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color.fromARGB(
                                                      255,
                                                      114,
                                                      107,
                                                      107,
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    NumberFormat.currency(
                                                      locale: 'en_US',
                                                      symbol: '₮ ',
                                                    ).format(
                                                      cartItem.variant?.price ??
                                                          cartItem
                                                              .product
                                                              .price,
                                                    ),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          (cartItem.variant !=
                                                                      null &&
                                                                  cartItem
                                                                          .variant
                                                                          ?.sellPrice !=
                                                                      null)
                                                              ? FontWeight
                                                                  .normal
                                                              : cartItem
                                                                      .product
                                                                      .sellPrice !=
                                                                  null
                                                              ? FontWeight
                                                                  .normal
                                                              : FontWeight.bold,
                                                      fontSize:
                                                          (cartItem.variant !=
                                                                      null &&
                                                                  cartItem
                                                                          .variant
                                                                          ?.sellPrice !=
                                                                      null)
                                                              ? 14
                                                              : cartItem
                                                                      .product
                                                                      .sellPrice !=
                                                                  null
                                                              ? 14
                                                              : 16,
                                                      color:
                                                          (cartItem.variant !=
                                                                      null &&
                                                                  cartItem
                                                                          .variant
                                                                          ?.sellPrice !=
                                                                      null)
                                                              ? Colors.grey
                                                              : cartItem
                                                                      .product
                                                                      .sellPrice !=
                                                                  null
                                                              ? Colors.grey
                                                              : Colors.black,
                                                      decoration:
                                                          (cartItem.variant !=
                                                                      null &&
                                                                  cartItem
                                                                          .variant
                                                                          ?.sellPrice !=
                                                                      null)
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : cartItem
                                                                      .product
                                                                      .sellPrice !=
                                                                  null
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : TextDecoration
                                                                  .none,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  if ((cartItem
                                                              .variant
                                                              ?.sellPrice ??
                                                          cartItem
                                                              .product
                                                              .sellPrice) !=
                                                      null)
                                                    Text(
                                                      NumberFormat.currency(
                                                        locale: 'en_US',
                                                        symbol: '₮ ',
                                                      ).format(
                                                        cartItem
                                                                .variant
                                                                ?.sellPrice ??
                                                            cartItem
                                                                .product
                                                                .sellPrice,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        height: 25,
                                                        width: 25,
                                                        child: TextButton(
                                                          onPressed: () async {
                                                            if (cartItem.qty >
                                                                1) {
                                                              final newQty =
                                                                  cartItem.qty -
                                                                  1;

                                                              setState(() {
                                                                cartItem.qty =
                                                                    newQty;
                                                                cartTotalPrice -=
                                                                    cartItem
                                                                        .sellPrice ??
                                                                    cartItem
                                                                        .price;
                                                              });
                                                              await updateCartItem(
                                                                cartItem.id,
                                                                newQty,
                                                              );
                                                            }
                                                          },
                                                          style: TextButton.styleFrom(
                                                            elevation: 0,
                                                            backgroundColor:
                                                                Colors.white,
                                                            foregroundColor:
                                                                Colors.pink,
                                                            padding:
                                                                EdgeInsets.zero,
                                                            shape:
                                                                const CircleBorder(),
                                                          ),
                                                          child: Icon(
                                                            Icons.remove,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Text('${cartItem.qty}'),
                                                      SizedBox(width: 12),
                                                      SizedBox(
                                                        height: 25,
                                                        width: 25,
                                                        child: TextButton(
                                                          onPressed: () async {
                                                            if (cartItem.qty <
                                                                5) {
                                                              final newQty =
                                                                  cartItem.qty +
                                                                  1;

                                                              setState(() {
                                                                cartItem.qty =
                                                                    newQty;
                                                                cartTotalPrice +=
                                                                    cartItem
                                                                        .sellPrice ??
                                                                    cartItem
                                                                        .price;
                                                              });
                                                              await updateCartItem(
                                                                cartItem.id,
                                                                newQty,
                                                              );
                                                            }
                                                          },
                                                          style: TextButton.styleFrom(
                                                            elevation: 0,
                                                            backgroundColor:
                                                                Colors.white,
                                                            foregroundColor:
                                                                Colors.pink,
                                                            padding:
                                                                EdgeInsets.zero,
                                                            shape:
                                                                const CircleBorder(),
                                                          ),
                                                          child: Icon(
                                                            Icons.add,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 30,
                                                    width: 30,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          if (cartItem
                                                                  .sellPrice !=
                                                              null) {
                                                            cartTotalPrice -=
                                                                cartItem
                                                                    .sellPrice! *
                                                                cartItem.qty;
                                                          } else {
                                                            cartTotalPrice -=
                                                                cartItem.price *
                                                                cartItem.qty;
                                                          }
                                                          _cartItems.remove(
                                                            cartItem,
                                                          );
                                                          deleteCartItem(
                                                            cartItem.id,
                                                          );
                                                        });
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        foregroundColor:
                                                            Colors.white,
                                                        shape:
                                                            const CircleBorder(),
                                                        padding:
                                                            EdgeInsets.zero,
                                                      ),
                                                      child: Icon(
                                                        Icons.delete,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            SizedBox(height: 12),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Нийт үнийн дүн: ',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'en_US',
                                      symbol: '₮ ',
                                    ).format(cartTotalPrice),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                : currentStep == 2
                ? Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              child: Text(
                                'Хаяг оруулах',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            SizedBox(height: 12),

                            SizedBox(
                              height: 200,
                              child: GridView.count(
                                crossAxisCount: 2,
                                childAspectRatio: 1,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  GestureDetector(
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color:
                                              orderType == 'delivery'
                                                  ? Colors.pink
                                                  : Colors.grey,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.store, size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                'Хүргэлт',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        orderType = 'delivery';
                                      });
                                    },
                                  ),
                                  GestureDetector(
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color:
                                              orderType == 'arrival'
                                                  ? Colors.pink
                                                  : Colors.grey,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.store, size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                'Очиж авах',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        orderType = 'arrival';
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 12),
                            TextField(
                              controller: provinceController,
                              decoration: InputDecoration(
                                labelText: 'Аймаг,хот',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 12),
                            TextField(
                              controller: districtController,
                              decoration: InputDecoration(
                                labelText: 'Сум, дүүрэг',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 12),
                            TextField(
                              controller: sectionController,
                              decoration: InputDecoration(
                                labelText: 'Баг, хороо',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 12),
                            TextField(
                              controller: addressController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Гудамж, байр тоот',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: cardHolderController,
                        decoration: InputDecoration(
                          labelText: 'Карт эзэмшигчийн нэр',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: cardNumberController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Картын дугаар',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: cardEndDateController,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                labelText: 'Дуусах хугацаа (MM/YY)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: cvvController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'CVV',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Нийт үнийн дүн: ${NumberFormat.currency(locale: 'en_US', symbol: '₮ ').format(cartTotalPrice)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
