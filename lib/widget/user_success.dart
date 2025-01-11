import 'package:emergencyconsultation/pages/user/user_mainpage.dart';
import 'package:flutter/material.dart';

class UserSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'You Have been Rescue', // Message after loading is done
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green, // Text color
                    ),
                  ),
                  SizedBox(height: 20), // Space between the message and the button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 0))); // Navigate back to the previous page
                    },
                    child: Text('Click this return to home page'), // Button text
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Button color
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Button padding
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}