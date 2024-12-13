import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User model serialization to map', () {
      final user = User(
        id: 1,
        firebaseUid: 'firebase_123',
        name: 'Test User',
        email: 'testuser@example.com',
        preferences: 'darkMode=true',
        password: 'test_password',
        profileImageBase64: 'image_base64_string',
        phoneNumber: '1234567890',
      );

      final userMap = user.toMap();

      expect(userMap['id'], 1);
      expect(userMap['firebase_uid'], 'firebase_123');
      expect(userMap['name'], 'Test User');
      expect(userMap['email'], 'testuser@example.com');
      expect(userMap['phoneNumber'], '1234567890');
      expect(userMap['preferences'], 'darkMode=true');
      expect(userMap['password'], 'test_password');
      expect(userMap['profileImageBase64'], 'image_base64_string');
    });

    test('User model deserialization from map', () {
      final map = {
        'id': 1,
        'firebase_uid': 'firebase_123',
        'name': 'Test User',
        'email': 'testuser@example.com',
        'phoneNumber': '1234567890',
        'preferences': 'darkMode=true',
        'password': 'test_password',
        'profileImageBase64': 'image_base64_string',
      };

      final user = User.fromMap(map);

      expect(user.id, 1);
      expect(user.firebaseUid, 'firebase_123');
      expect(user.name, 'Test User');
      expect(user.email, 'testuser@example.com');
      expect(user.phoneNumber, '1234567890');
      expect(user.preferences, 'darkMode=true');
      expect(user.password, 'test_password');
      expect(user.profileImageBase64, 'image_base64_string');
    });

    test('User model isDarkMode getter', () {
      final user = User(
        id: 1,
        firebaseUid: 'firebase_123',
        name: 'Test User',
        email: 'testuser@example.com',
        preferences: 'darkMode=true',
        password: 'test_password',
        profileImageBase64: 'image_base64_string',
        phoneNumber: '1234567890',
      );

      expect(user.isDarkMode, true);
    });

    test('User model setDarkMode method', () {
      final user = User(
        id: 1,
        firebaseUid: 'firebase_123',
        name: 'Test User',
        email: 'testuser@example.com',
        preferences: '',
        password: 'test_password',
        profileImageBase64: 'image_base64_string',
        phoneNumber: '1234567890',
      );

      user.setDarkMode(true);
      expect(user.preferences, 'darkMode=true');

      user.setDarkMode(false);
      expect(user.preferences, 'darkMode=false');
    });
  });
}
