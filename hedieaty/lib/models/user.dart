class User {
  final int? id;
  final String name;
  final String email;
  final String preferences;
  String password;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.preferences,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferences': preferences,
      'password': password,
    };
  }
}
