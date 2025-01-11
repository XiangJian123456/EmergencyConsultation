import 'package:flutter/material.dart';
import 'package:emergencyconsultation/pages/user/settings/user_settings.dart';

class NetworkTestScreen extends StatefulWidget {
  @override
  _NetworkTestScreenState createState() => _NetworkTestScreenState();
}

class _NetworkTestScreenState extends State<NetworkTestScreen> {
  String _networkStatus = "Evaluate Network Connection .....";
  bool _isConnected = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network Strength Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!_isConnected)
              Icon(Icons.wifi, size: 100, color: Colors.blue),
            if (_isConnected)
              Icon(Icons.check_circle, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              _networkStatus,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingPage()),
                );
              },
              child: Text("Returned"),
            ),
          ],
        ),
      ),
    );
  }
}