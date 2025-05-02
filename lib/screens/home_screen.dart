import 'package:flutter/material.dart';
import "./HomePages/home_page.dart";
import "./HomePages/product_page.dart";
import "./HomePages/services_page.dart";
import "./HomePages/account_page.dart";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:intl/intl.dart';
import '../screens/Order/orderCreate.dart';

import '../models/cartItem.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  String logoUrl =
      'https://logowik.com/content/uploads/images/hair-salon5230.logowik.com.webp';
  int _selectedIndex = 0;
  bool hasToken = false;

  String name = '';
  String avatar = '';

  int cartTotalPrice = 0;

  List<CartItem> _cartItems = [];
  int cartItemCount = 0;

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

  @override
  void initState() {
    super.initState();
    print("check token");
    checkToken();
    print(hasToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFF2949C),
        automaticallyImplyLeading: false,
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
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
                : Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        logoUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 24),
                    Text(
                      'Гоо сайхны салон',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      ),
      body: _pages[_selectedIndex],
      floatingActionButton:
          hasToken
              ? FloatingActionButton(
                shape: CircleBorder(),
                elevation: 0,
                backgroundColor: Colors.pink,
                onPressed: () async {
                  await fetchCartItems();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (
                          BuildContext context,
                          StateSetter modalSetState,
                        ) {
                          return SizedBox(
                            height: 650,
                            width: double.infinity,
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    150,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Таны сагс',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children:
                                                _cartItems.map((cartItem) {
                                                  return SizedBox(
                                                    height: 150,
                                                    width: double.infinity,
                                                    child: Card(
                                                      color: Colors.white,
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        side: const BorderSide(
                                                          color: Color.fromARGB(
                                                            255,
                                                            225,
                                                            224,
                                                            224,
                                                          ),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              16.0,
                                                            ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              child: Image.network(
                                                                cartItem.variant !=
                                                                        null
                                                                    ? cartItem
                                                                        .variant!
                                                                        .images[0]
                                                                    : cartItem
                                                                        .product
                                                                        .images[0],
                                                                width: 120,
                                                                height: 120,
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    cartItem
                                                                        .product
                                                                        .name,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                    softWrap:
                                                                        false,
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),

                                                                  if (cartItem
                                                                          .variant
                                                                          ?.title !=
                                                                      null)
                                                                    Text(
                                                                      cartItem
                                                                          .variant!
                                                                          .title,
                                                                      style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Color.fromARGB(
                                                                          255,
                                                                          114,
                                                                          107,
                                                                          107,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  const SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        NumberFormat.currency(
                                                                          locale:
                                                                              'en_US',
                                                                          symbol:
                                                                              '₮ ',
                                                                        ).format(
                                                                          cartItem.variant?.price ??
                                                                              cartItem.product.price,
                                                                        ),
                                                                        style: TextStyle(
                                                                          fontWeight:
                                                                              (cartItem.variant !=
                                                                                          null &&
                                                                                      cartItem.variant?.sellPrice !=
                                                                                          null)
                                                                                  ? FontWeight.normal
                                                                                  : cartItem.product.sellPrice !=
                                                                                      null
                                                                                  ? FontWeight.normal
                                                                                  : FontWeight.bold,
                                                                          fontSize:
                                                                              (cartItem.variant !=
                                                                                          null &&
                                                                                      cartItem.variant?.sellPrice !=
                                                                                          null)
                                                                                  ? 14
                                                                                  : cartItem.product.sellPrice !=
                                                                                      null
                                                                                  ? 14
                                                                                  : 16,
                                                                          color:
                                                                              (cartItem.variant !=
                                                                                          null &&
                                                                                      cartItem.variant?.sellPrice !=
                                                                                          null)
                                                                                  ? Colors.grey
                                                                                  : cartItem.product.sellPrice !=
                                                                                      null
                                                                                  ? Colors.grey
                                                                                  : Colors.black,
                                                                          decoration:
                                                                              (cartItem.variant !=
                                                                                          null &&
                                                                                      cartItem.variant?.sellPrice !=
                                                                                          null)
                                                                                  ? TextDecoration.lineThrough
                                                                                  : cartItem.product.sellPrice !=
                                                                                      null
                                                                                  ? TextDecoration.lineThrough
                                                                                  : TextDecoration.none,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            12,
                                                                      ),
                                                                      if ((cartItem.variant?.sellPrice ??
                                                                              cartItem.product.sellPrice) !=
                                                                          null)
                                                                        Text(
                                                                          NumberFormat.currency(
                                                                            locale:
                                                                                'en_US',
                                                                            symbol:
                                                                                '₮ ',
                                                                          ).format(
                                                                            cartItem.variant?.sellPrice ??
                                                                                cartItem.product.sellPrice,
                                                                          ),
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 12,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          SizedBox(
                                                                            height:
                                                                                25,
                                                                            width:
                                                                                25,
                                                                            child: TextButton(
                                                                              onPressed: () async {
                                                                                if (cartItem.qty >
                                                                                    1) {
                                                                                  final newQty =
                                                                                      cartItem.qty -
                                                                                      1;

                                                                                  modalSetState(
                                                                                    () {
                                                                                      cartItem.qty = newQty;
                                                                                      cartTotalPrice -=
                                                                                          cartItem.sellPrice ??
                                                                                          cartItem.price;
                                                                                    },
                                                                                  );
                                                                                  await updateCartItem(
                                                                                    cartItem.id,
                                                                                    newQty,
                                                                                  );
                                                                                }
                                                                              },
                                                                              style: TextButton.styleFrom(
                                                                                elevation:
                                                                                    0,
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
                                                                                size:
                                                                                    16,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                12,
                                                                          ),
                                                                          Text(
                                                                            '${cartItem.qty}',
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                12,
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                25,
                                                                            width:
                                                                                25,
                                                                            child: TextButton(
                                                                              onPressed: () async {
                                                                                if (cartItem.qty <
                                                                                    5) {
                                                                                  final newQty =
                                                                                      cartItem.qty +
                                                                                      1;

                                                                                  modalSetState(
                                                                                    () {
                                                                                      cartItem.qty = newQty;
                                                                                      cartTotalPrice +=
                                                                                          cartItem.sellPrice ??
                                                                                          cartItem.price;
                                                                                    },
                                                                                  );
                                                                                  await updateCartItem(
                                                                                    cartItem.id,
                                                                                    newQty,
                                                                                  );
                                                                                }
                                                                              },
                                                                              style: TextButton.styleFrom(
                                                                                elevation:
                                                                                    0,
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
                                                                                size:
                                                                                    16,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            30,
                                                                        width:
                                                                            30,
                                                                        child: ElevatedButton(
                                                                          onPressed: () {
                                                                            modalSetState(() {
                                                                              if (cartItem.sellPrice !=
                                                                                  null) {
                                                                                cartTotalPrice -=
                                                                                    cartItem.sellPrice! *
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
                                                                            size:
                                                                                16,
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
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
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
                                        SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.pink,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          OrderCreate(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Захиалга үүсгэх',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                tooltip: 'Add',
                child: Icon(Icons.shopping_cart, color: Colors.white),
              )
              : null,
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
