import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../models/service.dart';
import '../../models/serviceCategory.dart';
import '../ServiceDetail/serviceDetail.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ServiceCategory> _serviceCategories = [];
  List<Service> _services = [];
  int _selectedIndex = 0;
  bool loading = true;
  bool loadingServices = false;
  var selectedCategoryId = "";

  Future fetchCategories() async {
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
          _tabController = TabController(
            length: _serviceCategories.length,
            vsync: this,
          );
          selectedCategoryId = _serviceCategories[0].id;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (err) {
      print(err);
    }
  }

  Future fetchServices() async {
    try {
      setState(() {
        loading = true;
      });
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/services/list');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'filter': {'category': selectedCategoryId},
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          final jsonData = jsonDecode(response.body);
          _services =
              (jsonData['rows'] as List)
                  .map((eachService) => Service.fromJson(eachService))
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
    fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 10.0,
                children:
                    _serviceCategories.map((category) {
                      int index = _serviceCategories.indexOf(category);
                      return ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _selectedIndex = index;
                            selectedCategoryId = category.id;
                          });
                          await fetchServices();
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
                          side: BorderSide(color: Colors.pink, width: 1.5),
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
              ? SizedBox(
                height: 600,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.pink),
                ),)
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
                          _services.map((service) {
                            return GestureDetector(
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
                                              Text(
                                                service.title,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
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
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
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
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
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
                                        (context) => Servicedetail(
                                          serviceId: service.id,
                                        ),
                                  ),
                                );
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
