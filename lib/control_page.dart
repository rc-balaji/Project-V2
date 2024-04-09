import 'dart:io';
import 'package:flutter/material.dart';
import 'home_page.dart';

class ControlPage extends StatelessWidget {
  final NetworkInfo networkInfo;
  final Socket socket;

  ControlPage({required this.networkInfo, required this.socket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: ${networkInfo.name}'),
            Text('SSID: ${networkInfo.ssid}'),
            Text('Password: ${networkInfo.password}'),
            Text('IP: ${networkInfo.ip}'),
            ElevatedButton(
              onPressed: () => socket.write('ON'),
              child: Text('Turn On'),
            ),
            ElevatedButton(
              onPressed: () => socket.write('OFF'),
              child: Text('Turn Off'),
            ),
            ElevatedButton(
              onPressed: () => socket.write('STOP'),
              child: Text('Stop'),
            ),
          ],
        ),
      ),
    );
  }
}
