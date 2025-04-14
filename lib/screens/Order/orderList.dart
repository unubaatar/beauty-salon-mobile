import 'package:flutter/material.dart';
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

  Future fetchOrders() async {
    try {
      final url = Uri.parse('http://10.0.2.2:4004/api/v1/orders/getByCustomer');
      print('fetching');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'customer': widget.customer}),
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
      body:
          loading
              ? Center(child: CircularProgressIndicator(color: Colors.pink))
              : Padding(
                padding: const EdgeInsets.all(8),
                child: GridView.count(
                  crossAxisCount: 2,
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
              ),
    );
  }
}
