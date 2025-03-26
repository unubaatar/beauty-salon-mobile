import '../models/productVariant.dart';

class Product {
  final String id;
  final String name;
  final String description;
  List<String> images;
  List<ProductVariant> variants;
  final int price;
  final int? sellPrice;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.price,
    required this.variants,
    this.sellPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      images: List<String>.from(json['images'].map((image) => image)),
      price: json['price'],
      variants: List<ProductVariant>.from(
        json['variants'].map((variant) => ProductVariant.fromJson(variant)),
      ),
      sellPrice: json['sellPrice'],
    );
  }
}
