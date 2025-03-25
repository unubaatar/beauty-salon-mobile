
class ServiceCategory {
  final String id;
  final String title;
  final String description;
  final String image;


  ServiceCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
        id: json['_id'],
        title: json['title'],
        description: json['description'],
        image: json['image'],
    );
  }
}