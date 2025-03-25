class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
        firstName: json['firstName'],
        lastName: json['lastName'],
        phone: json['phone'],
        email: json['email'],
        id: json['_id']);
  }
}