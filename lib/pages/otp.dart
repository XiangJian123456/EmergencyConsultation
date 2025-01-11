/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:emergencyconsultation/auth/auth_service.dart';
class OTPVerificationScreen extends StatefulWidget {
  final String phone;
  final String role;
  OTPVerificationScreen({required this.phone, required this.role}); 
  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
final FirebaseAuth _auth = FirebaseAuth.instance;

User? user ;
  Timer? _timer;
  int _countdown = 0;
  
  @override
  void initState() {
    super.initState();
    user = _auth.currentUser; // Initialize user in initState
  }
  void _startCountdown() {
    setState(() {
      _countdown = 60;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _showResendDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Resend OTP"),
          content: const Text("Your new verification OTP will be sent to you."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Okay"),
            ),
          ],
        );
      },
    );
  }
Future<void> sendOTP(String phone, String role, BuildContext context) async {
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: phone,
    verificationCompleted: (PhoneAuthCredential credential) async {
      // Auto-retrieval or instant verification
      await FirebaseAuth.instance.signInWithCredential(credential);
      print('Auto-verification successful');
      // Navigate to the next screen based on the role
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => role == 'doctor' 
              ? DoctorMainPages() 
              : MainScreen(selectedIndex: 0),
        ),
      );
    },
    verificationFailed: (FirebaseAuthException e) {
      print('Verification failed: ${e.message}');
      Fluttertoast.showToast(
        msg: 'Verification failed: ${e.message}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    },
    codeSent: (String verId, int? resendToken) {
      verificationId = verId; // Store the verification ID
      print('OTP sent to $phone');
      // Navigate to OTP verification screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => OTPVerificationScreen(phone: phone, role: role),
        ),
      );
    },
    codeAutoRetrievalTimeout: (String verId) {
      verificationId = verId; // Store the verification ID
      print('Auto-retrieval timeout, verification ID: $verId');
    },
  );
}
  Future<void> verifyOTP(BuildContext context, String otp, String role) async {
  if (verificationId == null) {
    print('Verification ID is null. Please send OTP first.');
    return;
  }

  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: otp,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
    print('OTP verified successfully!');

    // Navigate to the next screen based on the role
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) =>
            role == 'doctor' ? DoctorMainPages() : MainScreen(selectedIndex: 0),
      ),
    );
  } catch (e) {
    print('Failed to verify OTP: $e');
  }
}
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'OTP Verification',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Enter the verification OTP we just sent you on your email.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                              return SizedBox(
                                width: 40,
                                height: 40,
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  decoration: InputDecoration(
                                    counterText: '',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  ),
                                  onChanged: (value) {
                                    if (value.length == 1 && index < 5) {
                                      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                                    } else if (value.isEmpty && index > 0) {
                                      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                                    }
                                  },
                                ),
                              );
                            }),
                           ),
                        const SizedBox(height: 20),
                        const Text(
                          'Didn\'t receive the verification OTP?',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _countdown == 0
                                  ? () {
                                _startCountdown();
                                _showResendDialog();
                              }
                                  : null,
                              child: Text(
                                'Resend again',
                                style: TextStyle(color: Colors.red[800]),
                              ),
                            ),
                            if (_countdown > 0)
                              Text(
                                ' $_countdown s',
                                style: TextStyle(color: Colors.black),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                String otp = _controllers.map((controller) => controller.text).join(''); // Get the OTP from the controller
                String role = 'user'; // Define the role (replace with actual logic)

                // Call the verifyOTP method from AuthService
                await AuthService().verifyOTP(context, otp, role); // Pass the context, OTP, and role

                // If verification is successful, show a success dialog
              },
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            ),
        );
    }
}
*/