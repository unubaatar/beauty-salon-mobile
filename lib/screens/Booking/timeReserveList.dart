import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  Future fetchTimeReserves() async {
    try {
      final url = Uri.parse(
        'http://10.0.2.2:4004/api/v1/timeReserves/getByCustomer',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'customerId': "67a228bea4d6cb41926e2ea2"}),
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
      appBar: AppBar(title: Text('Цаг захиалгууд') , backgroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.count(
          crossAxisCount: 2,
          children:
              _timeReserves.map((timeReserve) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
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
                        side: const BorderSide(color: Colors.grey, width: 2),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }
}
