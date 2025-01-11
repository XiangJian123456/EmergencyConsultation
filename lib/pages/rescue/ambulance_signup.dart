import 'package:country_picker/country_picker.dart';
import 'package:emergencyconsultation/auth/auth_service.dart';
import 'package:emergencyconsultation/pages/login.dart';
import 'package:emergencyconsultation/pages/signup.dart';
import 'package:flutter/material.dart';

class Ambulance_Signup extends StatefulWidget {
  Ambulance_Signup({super.key});

  @override
  State<Ambulance_Signup> createState() => _Ambulance_SignupState();
}

class _Ambulance_SignupState extends State<Ambulance_Signup> {
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
                        'Create Ambulance Account',
                        style: TextStyle(
                          fontSize: 24,
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
                    prefixIcon: const Icon(Icons.phone_outlined),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                      print("Both are not pressed this way");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'If you are not Ambulance Team, click here',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),                // Create Account Button
                SizedBox(height: 12),

                // Create Account Button
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
                        role: 'ambulance',
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
