class ProductCategory {
  final String id;
  final String title;
  final String image;

  ProductCategory({required this.id, required this.title, required this.image});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['_id'],
      title: json['title'],
      image: json['image'],
    );
  }
}
