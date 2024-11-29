class User {
  final int? id;
  final String firebaseUid;
  final String name;
  final String email;
  final String preferences;
  String password;

  User({
    this.id,
    required this.firebaseUid,
    required this.name,
    required this.email,
    required this.preferences,
    required this.password,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      firebaseUid: map['firebase_uid'],
      name: map['name'],
      email: map['email'],
      preferences: map['preferences'],
      password: map['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'name': name,
      'email': email,
      'preferences': preferences,
      'password': password,
    };
  }
}
