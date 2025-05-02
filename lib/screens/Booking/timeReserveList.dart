import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/timeReserve.dart';
import '../../screens/Booking/timeReserveDetail.dart';

class TimeReserveList extends StatefulWidget {
  const TimeReserveList({super.key});

  @override
  State<TimeReserveList> createState() => _TimeReserveListState();
}

class _TimeReserveListState extends State<TimeReserveList> {
  List<TimeReserve> _timeReserves = [];
  int count = 0;
  String? selectedStatus = "pending";

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool loading = true;

  final Map<String, String> statusMap = {
    'pending': 'Хүлээгдэж байна',
    'in process': 'Явцад байна',
    'complete': 'Дууссан',
  };

  Future fetchTimeReserves() async {
    try {
      setState(() {
        loading = true;
      });
      String? customerId = await _secureStorage.read(key: 'customerId');
      final url = Uri.parse(
        'http://10.0.2.2:4004/api/v1/timeReserves/getByCustomer',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'customerId': customerId, 'state': selectedStatus}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          count = jsonData['count'];
          _timeReserves =
              (jsonData['rows'] as List)
                  .map((eachItem) => TimeReserve.fromJson(eachItem))
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
    fetchTimeReserves();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Цаг товлолтууд'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Төлөв сонгох',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                isExpanded: true,
                onChanged: (value) {
                  setState(() async {
                    selectedStatus = value;
                    await fetchTimeReserves();
                  });
                },
                items:
                    statusMap.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
              ),
            ),
            loading
                ? SizedBox(
                  height: 600,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.pink),
                  ),
                )
                : GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    ..._timeReserves.map((timeReserve) {
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => TimeReservceDetail(
                                      timeReserveId: timeReserve.id,
                                    ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Захиалгын дугаар',
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  timeReserve.timeReserveNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text('Өдөр: ${timeReserve.dateTitle}'),
                                Text('Цаг: ${timeReserve.startTime}'),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
