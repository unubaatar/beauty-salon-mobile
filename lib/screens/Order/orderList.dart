import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../models/order.dart';
import '../Order/orderDetail.dart';

class OrderList extends StatefulWidget {
  final String? customer;
  const OrderList({super.key, required this.customer});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  bool loading = true;
  List<Order> _orders = [];

  String? selectedStatus = "pending";

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final Map<String, String> statusMap = {
    'pending': 'Хүлээгдэж байна',
    'in process': 'Явцад байна',
    'arrived': 'Ирсэн',
    'complete': 'Дууссан',
  };

  Future fetchOrders() async {
    try {
      setState(() {
        loading = true;
      });
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/orders/getByCustomer');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'customer': widget.customer,
          'state': selectedStatus,
        }),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _orders =
              (jsonData['rows'] as List)
                  .map((order) => Order.fromJson(order))
                  .toList();
        });
      } else {
        print('jiijii');
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
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Бүтээгдэхүүн захиалгууд'),
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
                    await fetchOrders();
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
                    ..._orders.map((order) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        OrderDetail(orderDetailId: order.id),
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
                                  order.orderNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text('Төлөв: ${order.state}'),
                                Text('Төрөл: ${order.orderType}'),
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
