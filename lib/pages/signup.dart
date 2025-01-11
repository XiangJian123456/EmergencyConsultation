import 'package:country_picker/country_picker.dart';
import 'package:emergencyconsultation/auth/auth_service.dart';
import 'package:emergencyconsultation/pages/doctor/doc_signup.dart';
import 'package:emergencyconsultation/pages/login.dart';
import 'package:emergencyconsultation/pages/rescue/ambulance_signup.dart';
import 'package:flutter/material.dart';


class SignUp extends StatefulWidget {
  SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _passwordError;
  Country selectedCountry = Country(
    phoneCode: '60',
    countryCode: 'MY',
    e164Sc:0,
    geographic: true,
    name: 'Malaysia',
    level: 1,
    example: '0123456789',
    displayName: 'Malaysia',
    displayNameNoCountryCode: 'Malaysia',
    e164Key: '',
  );
  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }
void _showSecretCodeDialog(BuildContext context) {
  final TextEditingController _secretCodeController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Enter Secret Code'),
        content: TextField(
          controller: _secretCodeController,
          decoration: const InputDecoration(hintText: "Secret Code"),
          obscureText: true, // Optional: hide the input
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              String enteredCode = _secretCodeController.text;
              if (enteredCode == '123456789') { // Replace with your actual secret code
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Ambulance_Signup()),
                );
              } else {
                // Show an error message if the code is incorrect
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Incorrect secret code. Please try again.')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}
  void _validatePassword() {
    setState(() {
      if (_passwordController.text.length < 8) {
        _passwordError = 'Password must be at least 8 characters';
      } else if (_passwordController.text.length > 25) {
        _passwordError = 'Password must be less than 25 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: _phoneController.text.length));
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Header Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.shade50,
                        ),
                        child: Icon(
                          Icons.person_add,
                          size: 50,
                          color: Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Create User Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign up to get started',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Doctor Switch Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Are you Doctor?',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Doc_SignUp()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Switch to Doctor',
                          style: TextStyle(color: Colors.white60),),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _passwordError,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_android),
                    hintText: 'Phone Number',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showSecretCodeDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Both are not press this way',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      String phoneNumber = _phoneController.text;
                      if (phoneNumber.startsWith('+') && phoneNumber.length > 3) {
                      await AuthService().registerUser(
                        email: _emailController.text,
                        password: _passwordController.text,
                        phone: phoneNumber,
                        context: context,
                        role: 'user',
                      );
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a valid phone number in E.164 format.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
