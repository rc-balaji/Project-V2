import 'dart:io';
import 'package:flutter/material.dart';
import 'wifi_list_page.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'control_page.dart';

class NetworkInfo {
  String name;
  String ssid;
  String password;
  String ip;

  NetworkInfo(this.name, this.ssid, this.password, this.ip);
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<NetworkInfo> _networks = [];
  bool _isConnecting = false;
  NetworkInfo? _currentNetwork;

  void _addNetwork(String name, String ssid, String password, String ip) {
    setState(() {
      _networks.add(NetworkInfo(name, ssid, password, ip));
    });
  }

  void _showNetworkInfo(NetworkInfo network) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Network Info"),
          content: Text(
              "Name: ${network.name}\nSSID: ${network.ssid}\nPassword: ${network.password}\nIP Address: ${network.ip}"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _connectToWiFiOnly(NetworkInfo network) async {
    setState(() {
      _isConnecting = true;
    });
    try {
      await WiFiForIoTPlugin.connect(network.ssid,
          password: network.password, security: NetworkSecurity.WPA);
      setState(() {
        _currentNetwork = network;
        _isConnecting = false;
      });
    } catch (e) {
      setState(() {
        _isConnecting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to ${network.name}')));
    }
  }

  void _navigateToControlPage(NetworkInfo network) async {
    final socket = await Socket.connect(network.ip, 80).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to connect to server')));
    });
    if (socket != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ControlPage(networkInfo: network, socket: socket)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Column(
        children: [
          if (_currentNetwork != null)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Connected to: ${_currentNetwork!.name}"),
                  Text("IP: ${_currentNetwork!.ip}"),
                  ElevatedButton(
                    onPressed: () => _navigateToControlPage(_currentNetwork!),
                    child: Text('Go to Control Page'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _networks.length,
              itemBuilder: (context, index) {
                NetworkInfo network = _networks[index];
                return ListTile(
                  title: Text(network.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () => _connectToWiFiOnly(network),
                        child: Text('Connect'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _showNetworkInfo(network),
                        child: Text('Info'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isConnecting) CircularProgressIndicator(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return WifiListPage();
          }));
        },
        child: Icon(Icons.wifi),
      ),
    );
  }
}
