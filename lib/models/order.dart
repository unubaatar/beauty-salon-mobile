import '../models/customer.dart';
import '../models/cartItem.dart';

class Order {
  final String id;
  final Customer customer;
  final List<CartItem>? items;
  final String orderNumber;
  final String state;
  final int totalAmount;
  // final String address;
  final String orderType;

  Order({
    required this.id,
    required this.customer,
    required this.items,
    required this.orderNumber,
    required this.state,
    required this.totalAmount,
    // required this.address,
    required this.orderType,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      customer: Customer.fromJson(json['customer']),
      items:
          json['items'] != null
              ? List<CartItem>.from(
                json['items'].map((item) => CartItem.fromJson(item)),
              )
              : null,
      orderNumber: json['orderNumber'],
      state: json['state'],
      totalAmount: json['totalAmount'],
      // address: json['address'],
      orderType: json['orderType'],
    );
  }
}
