// lib/models/customer.dart

class Customer {
  final String phoneNumber;
  final String name;
  double points;

  Customer({
    required this.phoneNumber,
    required this.name,
    this.points = 0.0,
  });
}