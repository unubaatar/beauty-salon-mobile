
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/service.dart';
import '../../screens/Booking/booking.dart';
import '../../models/serviceVariant.dart';

class Servicedetail extends StatefulWidget {
  final String serviceId;
  const Servicedetail({super.key, required this.serviceId});

  @override
  State<Servicedetail> createState() => _ServicedetailState();
}

class _ServicedetailState extends State<Servicedetail> {
  late ServiceVariant? selectedVariant = null;
  late Service service;
  bool loaing = true;
  late List<bool> _selectedVariants;

  Future fetchServiceData() async {
    try {
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/services/getById');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'_id': widget.serviceId}));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          service = Service.fromJson(jsonData);
          if (service.variants != null && service.variants!.isNotEmpty) {
            _selectedVariants =
                List.generate(service.variants!.length, (index) => false);
            selectedVariant =
                (service.variants != null && service.variants!.isNotEmpty
                    ? ServiceVariant(
                        id: service.variants![0].id,
                        title: service.variants![0].title,
                        price: service.variants![0].price,
                        body: service.variants![0].body,
                        duration: service.variants![0].duration,
                      )
                    : null);
            _selectedVariants[0] = true;
          }

          loaing = false;
        });
      } else {
        print("Error fetching data");
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchServiceData();
  }

  @override
  Widget build(BuildContext context) {
    return loaing
        ? const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(service.title),
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.network(
                    service.image,
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
                            Text(
                              service.title,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Chip(
                              backgroundColor:
                                  const Color.fromARGB(255, 199, 44, 83),
                              surfaceTintColor:
                                  const Color.fromARGB(255, 199, 44, 83),
                              label: Text(
                                service.category.title,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                              labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              visualDensity: const VisualDensity(
                                  horizontal: -4.0, vertical: -4.0),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(service.description),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                                child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                                    child: const Icon(Icons.timelapse)),
                                Text(
                                  '${selectedVariant != null ? selectedVariant?.duration : service.duration} минут',
                                  style: TextStyle(fontSize: 16),
                                )
                              ],
                            )),
                            Expanded(
                                child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                                    child: const Icon(Icons.money_rounded)),
                                Text(
                                  '${selectedVariant != null ? selectedVariant?.price : service.price}₮',
                                  style: TextStyle(fontSize: 16),
                                )
                              ],
                            )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        service.variants != null && service.variants!.isNotEmpty
                            ? Container(
                                alignment: Alignment.topLeft,
                                child: Wrap(
                                  spacing: 10.0,
                                  children: service.variants!.map((variant) {
                                    int index =
                                        service.variants!.indexOf(variant);
                                    return ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          for (int i = 0;
                                              i < _selectedVariants.length;
                                              i++) {
                                            _selectedVariants[i] = i == index;
                                          }
                                          selectedVariant = variant;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(100, 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 8.0),
                                        backgroundColor:
                                            _selectedVariants[index]
                                                ? const Color.fromARGB(
                                                    255, 199, 44, 83)
                                                : Colors.white,
                                        side: const BorderSide(
                                          color:
                                              Color.fromARGB(255, 199, 44, 83),
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Text(
                                        variant.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: _selectedVariants[index]
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            : const SizedBox(
                                height: 0,
                              ),
                        const SizedBox(
                          height: 100,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomSheet: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const BookingPage()));
                        },
                        child: const Text("Цаг товлох"),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 199, 44, 83)),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
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