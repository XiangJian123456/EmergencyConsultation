
import 'package:emergencyconsultation/notification/firebase_api.dart';
import 'package:emergencyconsultation/notification/notification_service.dart';
import 'package:emergencyconsultation/pages/doctor/doc_mainpages.dart';
import 'package:emergencyconsultation/pages/rescue/rescue_mainpages.dart';
import 'package:emergencyconsultation/pages/user/user_mainpage.dart';
import 'package:emergencyconsultation/widget/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
       FlutterLocalNotificationsPlugin();

   void initializeNotifications() {
     const AndroidInitializationSettings initializationSettingsAndroid =
         AndroidInitializationSettings('@mipmap/ic_launcher');

     final InitializationSettings initializationSettings =
         InitializationSettings(
       android: initializationSettingsAndroid,
     );

     flutterLocalNotificationsPlugin.initialize(initializationSettings);
   }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotification();
  await NotificationService.instance.initialize();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/doctor': (context) => const DoctorMainPages(), 
        '/userhome': (context) => const MainScreen(selectedIndex: 0,),
        '/ambulance': (context) => const AmbulanceMainPages(),
      },
    );
  }
}





