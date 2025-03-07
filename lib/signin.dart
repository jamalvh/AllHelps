import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:allhelps/main.dart'; // Assuming NavBarPage is here

class SignInPage extends StatefulWidget {
  final int selectedIndex;
  final Function(int, {String? filter}) onIndexChanged;

  const SignInPage(
      {super.key, required this.selectedIndex, required this.onIndexChanged});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isSignIn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 15,
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isSignIn ? 'Sign In' : 'Sign Up',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_isSignIn) ...[
                    _buildTextField(
                      controller: _firstNameController,
                      hintText: 'First Name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _lastNameController,
                      hintText: 'Last Name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                  ],
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () => _handleAuthentication(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _isSignIn ? 'Sign In' : 'Sign Up',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignIn = !_isSignIn;
                      });
                    },
                    child: Text(
                      _isSignIn
                          ? 'Don\'t have an account? Sign Up'
                          : 'Already have an account? Sign In',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  void _handleAuthentication() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (_isSignIn) {
          // Sign In
          await _auth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          _showSuccessAndNavigate('Logged In Successfully');
        } else {
          // Sign Up
          UserCredential userCredential =
              await _auth.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          await userCredential.user!
              .updateDisplayName(_firstNameController.text.trim());
          // Store additional user info in Firestore
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'email': _emailController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

          _showSuccessAndNavigate('Successfully Signed Up');
        }
      } on FirebaseAuthException catch (e) {
        _showErrorSnackBar(e.message ?? 'An error occurred');
      }
    }
  }

  void _showSuccessAndNavigate(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => NavBarPage(
                onIndexChanged: widget.onIndexChanged,
                selectedIndex: widget.selectedIndex,
              )),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
