// lib/models/staff.dart

class Staff {
  final String username;
  final String password;
  final String role; // Ruoli possibili: 'waiter', 'cook', 'owner'

  Staff({
    required this.username,
    required this.password,
    required this.role,
  });
}