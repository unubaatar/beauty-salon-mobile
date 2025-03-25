import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/service.dart';
import '../../models/serviceCategory.dart';
import '../ServiceDetail/serviceDetail.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ServiceCategory> _serviceCategories = [];
  List<Service> _services = [];
  bool loading = true;
  bool loadingServices = false;
  var selectedCategoryId = "";

  Future fetchCategories() async {
    try {
      final url =
          Uri.parse('http://10.0.2.2:4004/api/v1/serviceCategories/list');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _serviceCategories = (jsonData['rows'] as List)
              .map((eachCategory) => ServiceCategory.fromJson(eachCategory))
              .toList();
          _tabController =
              TabController(length: _serviceCategories.length, vsync: this);
          _tabController.addListener(_onTabChanged);
          selectedCategoryId = _serviceCategories[0].id;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
      loading = false;
    } catch (err) {
      print(err);
    }
  }

  Future fetchServices() async {
    try {
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/services/list');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'filter': {'category': selectedCategoryId}
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          final jsonData = jsonDecode(response.body);
          _services = (jsonData['rows'] as List)
              .map((eachService) => Service.fromJson(eachService))
              .toList();
        });
      } else {
        print("jiijii");
      }
    } catch (err) {
      print(err);
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        selectedCategoryId = _serviceCategories[_tabController.index].id;
      });
      fetchServices();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : DefaultTabController(
            length: _serviceCategories.length,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabAlignment: TabAlignment.center,
                  tabs: _serviceCategories.map((category) {
                    return Tab(text: category.title);
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      GridView.count(
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _services.map((service) {
                          return GestureDetector(
                              child: Card(
                                  child: Column(
                                children: [
                                  Image.network(
                                    service.image,
                                    width: double.infinity,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 4, 12, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              service.title,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 1,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Үнэ:  ${service.price}₮',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade800,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 1,
                                        ),
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
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Servicedetail(
                                            serviceId: service.id)));
                              });
                        }).toList(),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
  }
}