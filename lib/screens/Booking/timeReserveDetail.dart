import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/timeReserve.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TimeReservceDetail extends StatefulWidget {
  final String timeReserveId;
  const TimeReservceDetail({super.key, required this.timeReserveId});

  @override
  State<TimeReservceDetail> createState() => _TimeReservceDetailState();
}

class _TimeReservceDetailState extends State<TimeReservceDetail> {
  bool loading = true;
  TimeReserve? timeReserve;
  Future fetchTimeReserve() async {
    try {
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/timeReserves/getById');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'_id': widget.timeReserveId}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          timeReserve = TimeReserve.fromJson(jsonData);
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
    fetchTimeReserve();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Захиалгын дэлгэрэнгүй'),
        backgroundColor: Colors.white,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  QrImageView(
                    data:
                        'http://localhost:4000/timeRequests/${timeReserve?.id}',
                    size: 200,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    '${timeReserve?.timeReserveNumber}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  SizedBox(
                    width: 350,
                    child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side:
                                const BorderSide(color: Colors.grey, width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    const Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Нэр:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${timeReserve?.customer.firstName}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ))
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    const Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Утас:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${timeReserve?.customer.phone}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ))
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    const Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Захиалгын дугаар:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${timeReserve?.timeReserveNumber}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ))
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    const Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Огноо:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${timeReserve?.dateTitle}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ))
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    const Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Цаг:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${timeReserve?.startTime}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ))
                                  ],
                                ),
                              )
                            ],
                          ),
                        )),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 350,
                    child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side:
                                const BorderSide(color: Colors.grey, width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              ...timeReserve?.services.map((item) {
                                    return Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 3,
                                                child: Text(
                                                  '${item.service.title}:',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                '${item.price}₮',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ));
                                  }).toList() ??
                                  [],
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    const Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Нийт дүн :',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${timeReserve?.totalAmount}₮',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                                     Padding(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    const Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Нийт хугацаа :',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${timeReserve?.totalDuration} минут',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    const Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Төлөв :',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${timeReserve?.state}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                          flex: 3,
                                          child: Text(
                                            'Төлбөрийн төлөв:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${timeReserve?.paymentState}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  )),
                            ],
                          ),
                        )),
                  )
                ],
              ),
            ),
    );
  }
}