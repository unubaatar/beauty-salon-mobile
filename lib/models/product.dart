import '../models/productVariant.dart';
import '../models/productCategory.dart';

class Product {
  final String id;
  final String name;
  final String description;
  List<String> images;
  List<ProductVariant> variants;
  final ProductCategory category;
  final int price;
  final int? sellPrice;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.price,
    required this.variants,
    required this.category,
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
      category: ProductCategory.fromJson(json['category'])
    );
  }
}
