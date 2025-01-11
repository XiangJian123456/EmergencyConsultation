import 'package:flutter/material.dart';

class EmailForget extends StatefulWidget {
  const EmailForget({super.key});

  @override
  State<EmailForget> createState() => _EmailForgetState();
}

class _EmailForgetState extends State<EmailForget> {
  final _email = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                const Text('Enter your Account Email. ', style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                ),
              const SizedBox(height: 20),
                TextField(
                controller: _email,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
              ),
             const SizedBox(height: 20,),
             ElevatedButton(
                  onPressed: (){},
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.orange,
                 padding: const EdgeInsets.symmetric(horizontal: 80, vertical:15),
               ),
                child: const Text('Confirm',style: TextStyle(
                   fontSize: 12,
                    fontWeight: FontWeight.bold,
                ),

                ),



                  ),
            ],

          ),
        ),
      ),
    );
  }
}
