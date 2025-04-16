import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../ServiceDetail/serviceDetail.dart';
import '../ProductDetail/productDetail.dart';

import '../../models/service.dart';
import "../../models/productCategory.dart";
import "../../models/serviceCategory.dart";
import "../../models/product.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Service> _servicesData = [];
  List<Product> _productsData = [];
  List<ServiceCategory> _serviceCategories = [];
  List<ProductCategory> _productCategories = [];

  int count = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchServices();
    fetchProducts();
    fetchProductCategories();
    fetchServiceCategories();
  }

  Future fetchProducts() async {
    try {
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/products/getLatest');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _productsData =
              (jsonData as List)
                  .map((eachService) => Product.fromJson(eachService))
                  .toList();
        });
      } else {
        print("jiijii");
      }
    } catch(err) {
      print(err);
    }
  }

  Future<void> fetchServices() async {
    try {
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/services/getLatest');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _servicesData =
              (jsonData as List)
                  .map((eachService) => Service.fromJson(eachService))
                  .toList();
        });
        loading = false;
      } else {
        loading = false;
        print("jiijii");
      }
    } catch (err) {
      print(err);
    }
  }

  Future fetchServiceCategories() async {
    try {
      final url = Uri.parse(
        'http://10.0.2.2:4004/api/v1/serviceCategories/list',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _serviceCategories =
              (jsonData['rows'] as List)
                  .map((eachCategory) => ServiceCategory.fromJson(eachCategory))
                  .toList();
        });
      } else {
        print('jiijii');
      }
    } catch (err) {
      print(err);
    }
  }

  Future fetchProductCategories() async {
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
          _productCategories =
              (jsonData['rows'] as List)
                  .map((eachCategory) => ProductCategory.fromJson(eachCategory))
                  .toList();
        });
      } else {
        print('jiijii');
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: ListView(
            children: [
              SizedBox(height: 20,),
              // Card(
              //   elevation: 0,
              //   color: Colors.white,
              //   child: Padding(
              //     padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           'Гоо сайхны салоны системд тавтай морил',
              //           style: TextStyle(
              //             fontSize: 22,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //         SizedBox(height: 12),
              //         Text(
              //           'Та манай салоноос өөрийн хүссэн үйлчилгээг цаг товлон авах боломжтой бөгөөд, гоо сайхны бүтээгдэхүүнийг гадаадаас захиалгаар авах боломжтой.',
              //           style: TextStyle(fontSize: 16),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Үйлчилгээний төрлүүд',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.fromLTRB(4, 16, 4, 16),
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _serviceCategories.length,
                  itemBuilder: (context, index) {
                    final category = _serviceCategories[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.pink, width: 3),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                category.image,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          SizedBox(
                            width: 100,
                            child: Text(
                              category.title,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Text(
                'Сүүлд нэмэгдсэн',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 440,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.9,
                  physics: NeverScrollableScrollPhysics(),
                  children:
                      _servicesData.map((service) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        Servicedetail(serviceId: service.id),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                              side: BorderSide(
                                color: Color.fromARGB(255, 223, 221, 221),
                                width: 2,
                              ),
                            ),

                            child: Column(
                              children: [
                                Image.network(
                                  service.image,
                                  width: double.infinity,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    4,
                                    12,
                                    0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 150,
                                            child: Text(
                                              service.title,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 1),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            NumberFormat.currency(
                                              locale: 'en_US',
                                              symbol: '\₮ ',
                                            ).format(service.price),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade800,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.timer, size: 14),
                                              SizedBox(width: 2),
                                              Text(
                                                '${service.duration} мин',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        service.description
                                                .split(' ')
                                                .take(4)
                                                .join(' ') +
                                            (service.description
                                                        .split(' ')
                                                        .length >
                                                    4
                                                ? '...'
                                                : ''),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              Text(
                'Бүтээгдэхүүний төрлүүд',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(4, 16, 4, 16),
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _productCategories.length,
                  itemBuilder: (context, index) {
                    final category = _productCategories[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.pink, width: 3),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                category.image,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          SizedBox(
                            width: 100,
                            child: Text(
                              category.title,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Text(
                'Сүүлд нэмэгдсэн',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 16,),
              SizedBox(
                height: 440,
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.9,
                  physics: NeverScrollableScrollPhysics(),
                  children:
                      _productsData.map((product) {
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
                                          child:  
                                          SizedBox( width: 150, child:Text(
                                            product.name,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ), ) 
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                            8,
                                            4,
                                            8,
                                            0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
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
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProductDetail(
                                          productId: product.id,
                                        ),
                                  ),
                                );
                              },
                            );
                      }).toList(),
                ),
              ),
            ],
          ),
        );
  }
}
