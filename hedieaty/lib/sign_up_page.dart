import 'package:flutter/material.dart';
import 'sign_in_page.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignUpPage({super.key});

  void _signUp(BuildContext context) {
    // TODO sign-up logic with FireBase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign up successful! Please sign in.')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
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
                  'Create Account',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.amber[500]),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign up to get started',
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
                  onPressed: () => _signUp(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                      backgroundColor: Colors.amber[500],
                  ),
                  child: const Text('Sign Up', style: TextStyle(fontSize: 18,color: Colors.white)),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
                  },
                  child: const Text('Already have an account? Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
