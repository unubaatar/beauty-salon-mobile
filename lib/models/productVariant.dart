class ProductVariant {
  final String id;
  final String title;
  final int price;
  final int? sellPrice;
  List<String> images;

  ProductVariant({
    required this.id,
    required this.title,
    required this.price,
    this.sellPrice,
    required this.images,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['_id'],
      title: json['title'],
      price: json['price'],
      sellPrice: json['sellPrice'],
      images: List<String>.from(json['images'].map((image) => image)),
    );
  }
}
