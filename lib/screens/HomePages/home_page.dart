import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Service> _servicesData = [];
  int count = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/services/list');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _servicesData = (jsonData['rows'] as List)
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

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: [
              Container(
                height: 225,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _servicesData.length,
                  itemBuilder: (context, index) {
                    final service = _servicesData[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 4,
                      child: Container(
                        width: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              service.image,
                              width: double.infinity,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(service.title),
                                      Chip(
                                        label: Text(
                                          service.category.title,
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        labelPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 0),
                                        visualDensity: const VisualDensity(
                                            horizontal: -4.0, vertical: -4.0),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    service.description
                                            .split(' ')
                                            .take(8)
                                            .join(' ') +
                                        (service.description.split(' ').length >
                                                8
                                            ? '...'
                                            : ''),
                                    style: const TextStyle(fontSize: 12),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          );
  }
}