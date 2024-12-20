import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:hedieaty/controllers/repository.dart';
import '../controllers/theme_notifier.dart';
import '../models/notification.dart';
import '../models/user.dart';
import 'sign_up_page.dart';
import '../main.dart';
import 'package:hedieaty/controllers/sync_controller.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final Repository _repository = Repository();

  SignInPage({super.key= const Key('SignInPageKey')}); // For Testing



  Future<void> onUserSignIn(int userId) async {
    SyncController syncController = SyncController();
    await syncController.syncUserData(userId);
    //print('User data synchronized successfully.');
  }


  Future<void> _saveUserLogin(int userId, String userName, String email,int firebaseId, String phoneNumber, String preferences, String? profileImageBase64) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    await prefs.setInt('firebaseId', firebaseId);
    await prefs.setString('firebaseUId', firebaseId.toString());
    await prefs.setString('userName', userName);
    await prefs.setString('email', email);
    await prefs.setString('phoneNumber', phoneNumber);
    await prefs.setString('preferences', preferences);
    await _repository.saveImageToSharedPrefs(firebaseId.toString(),profileImageBase64);
    onUserSignIn(userId);
  }

  Future<void> _signIn(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;

    // Check network connectivity
    if (! await _repository.isOnline()) {
      // Device is offline, use local authentication
      User? user = await _repository.authenticateUser(email, password);
      if (user != null) {
        await _handleUserSignIn(context, user);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged in offline. Limited functionality available.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password. Note: Email might not be registered offline.')),
        );
      }
    } else {
      // Device is online, use Firebase Authentication
      try {
        firebase_auth.UserCredential userCredential = await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? user = await _repository.authenticateUser(email, password);
        // print(user?.id!);
        if (user != null) {
          await _handleUserSignIn(context, user);

          // Load user preferences
          final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
          themeNotifier.loadUserPreferences(user.id.toString());

          // Get FCM Token
          final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
          String? token = await _firebaseMessaging.getToken();
          // print('FCM Token on Login: $token');

          // Update Firestore with the FCM Token
          QuerySnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('id', isEqualTo: user.id)
              .get();

          if (userSnapshot.docs.isNotEmpty) {
            DocumentReference userDocRef = userSnapshot.docs.first.reference;
            await userDocRef.set({
              'fcmToken': token,
            }, SetOptions(merge: true));
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: ${e.toString().replaceAll("[firebase_auth/invalid-credential]", '').replaceAll("[firebase_auth/invalid-email]", '')}')),
        );
      }
    }
  }

  Future<void> _handleUserSignIn(BuildContext context, User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedUserId = prefs.getInt('userId');

    if (savedUserId != null && savedUserId != user.id) {
     await prefs.clear();
    }

    await _saveUserLogin(user.id!, user.name, user.email, user.firebaseUid.hashCode, user.phoneNumber!, user.preferences, user.profileImageBase64);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/Logo.png', height: 100),
                const SizedBox(height: 20),
                Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.amber[500]),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                TextField(
                  key: const Key('emailField'), // Key for testing
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  key: const Key('passwordField'), // Key for testing
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  key: const Key('signInButton'), // Key for testing
                  onPressed: () => _signIn(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor: Colors.amber[500],
                  ),
                  child: const Text('Sign In', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: const Text('Don’t have an account? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
