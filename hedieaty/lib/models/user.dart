class User {
  final int? id;
  final String firebaseUid;
  final String name;
  final String email;
  final String preferences;
  String password;
  final String? profileImageBase64;

  User({
    this.id,
    required this.firebaseUid,
    required this.name,
    required this.email,
    required this.preferences,
    required this.password,
    this.profileImageBase64,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      firebaseUid: map['firebase_uid'],
      name: map['name'],
      email: map['email'],
      preferences: map['preferences'],
      password: map['password'],
      profileImageBase64: map['profileImageBase64'],
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
      'profileImageBase64': profileImageBase64,
    };
  }
}
