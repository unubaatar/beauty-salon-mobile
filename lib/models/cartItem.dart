import '../models/product.dart';
import '../models/productVariant.dart';
import '../models/customer.dart';

class CartItem {
  final String id;
  final Customer customer;
  final Product product;
  final ProductVariant? variant;
  int qty;
  final int price;
  final int? sellPrice;
  final int totalPrice;

  CartItem({
    required this.id,
    required this.customer,
    required this.product,
    this.variant,
    required this.qty,
    required this.price,
    this.sellPrice,
    required this.totalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'],
      customer: Customer.fromJson(json['customer']),
      product: Product.fromJson(json['product']),
      variant:
          json['variant'] != null
              ? ProductVariant.fromJson(json['variant'])
              : null,
      qty: json['qty'],
      price: json['price'],
      sellPrice: json['sellPrice'],
      totalPrice: json['totalPrice'],
    );
  }
}
