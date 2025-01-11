/*import 'package:emergencyconsultation/auth/auth_service.dart';
import 'package:emergencyconsultation/pages/otp.dart';
import 'package:flutter/material.dart';

class OTPRequestScreen extends StatelessWidget {
  final String phone;
  final String role;
  OTPRequestScreen({required this.phone, required this.role}) {
    print('Phone number passed: $phone'); // Print the phone number
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Forget Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'We will send an OTP to the following phone number:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
               'Display the passed phone number',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                onPressed: () async {
                  // Show a loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(child: CircularProgressIndicator()),
                  );

                  try {
                    // Call the sendOTP method from AuthService
                    await AuthService().sendOTP(phone, role,context); // Pass the phone number

                    // Navigate to OTPVerificationScreen after sending OTP
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OTPVerificationScreen(phone: phone , role: role), // Pass the phone number
                      ),
                    );
                  } catch (e) {
                    // Handle any errors that occur during OTP sending
                    print('Error sending OTP: $e');
                  } finally {
                    // Dismiss the loading indicator
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'Request OTP',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Optional: Add a loading indicator here
            ],
          ),
        ),
      ),
    );
  }
}
*/