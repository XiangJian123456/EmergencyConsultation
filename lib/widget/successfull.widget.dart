import 'package:emergencyconsultation/pages/doctor/doc_mainpages.dart';
import 'package:emergencyconsultation/pages/user/user_mainpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ConsultationCompletedWidget extends StatelessWidget {
 final bool isUser;
 final bool isDoctor;
 final currentUser = FirebaseAuth.instance.currentUser;
 ConsultationCompletedWidget({
   super.key, required this.isUser, 
   required this.isDoctor
 });
  @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text('Consultation Completed'),
     ),
     body: Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: <Widget>[
           Icon(
             Icons.check_circle_outline,
             color: Colors.green,
             size: 100.0,
           ),
           SizedBox(height: 20),
           Text(
             'Your consultation has been successfully completed!',
             style: TextStyle(
               fontSize: 20,
               fontWeight: FontWeight.bold,
             ),
             textAlign: TextAlign.center,
           ),
           SizedBox(height: 20),
           ElevatedButton(
             onPressed: () {
                 Navigator.of(context).pushReplacement(
                   MaterialPageRoute(
                     builder: (context) => DoctorMainPages(),
                   ),
                 );

             },
             child: Text('Back to Home'),
           ),
         ],
       ),
     ),
   );
 }
}