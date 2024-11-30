import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:connectivity_plus/connectivity_plus.dart'; // For checking internet connectivity
import 'package:hedieaty/controllers/repository.dart';
import '../models/user.dart';
import 'sign_up_page.dart';
import '../main.dart';

class SignInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final Repository _repository = Repository();

  SignInPage({super.key});

  Future<void> _saveUserLogin(int userId, String userName, String email,int firebaseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    await prefs.setInt('firebaseId', firebaseId);
    await prefs.setString('userName', userName);
    await prefs.setString('email', email);
  }

  Future<void> _signIn(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;

    // Check network connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult[0] == ConnectivityResult.none) {
      // Device is offline, use local authentication
      User? user = await _repository.authenticateUser(email, password);
      if (user != null) {
        await _saveUserLogin(user.id!, user.name, user.email, user.firebaseUid.hashCode); // Save user ID and name
        // Show offline login message
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
        if (user != null) {
          await _saveUserLogin(user.id!, user.name, user.email, user.firebaseUid.hashCode); // Save user ID and name
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
        // Handle network error appropriately by falling back to local authentication
        if (e.toString().contains('network error')) {
          User? user = await _repository.authenticateUser(email, password);
          if (user != null) {
            await _saveUserLogin(user.id!, user.name, user.email,user.firebaseUid.hashCode); // Save user ID and name
            // Show offline login message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged in offline due to network error. Limited functionality available.')),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign in failed: $e')),
          );
        }
      }
    }
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
