import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WifiListPage extends StatefulWidget {
  final Function(String ssid, String password, String ip) onConnected;

  WifiListPage({required this.onConnected});

  @override
  _WifiListPageState createState() => _WifiListPageState();
}

class _WifiListPageState extends State<WifiListPage> {
  List<WifiNetwork> _networks = [];
  final TextEditingController _passwordController = TextEditingController();
  bool _isScanning = false;
  bool _isPasswordVisible = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _scanWifiNetworks();
  }

  Future<void> _scanWifiNetworks() async {
    setState(() {
      _isScanning = true;
    });
    List<WifiNetwork> list = await WiFiForIoTPlugin.loadWifiList();
    setState(() {
      _networks = list;
      _isScanning = false;
    });
  }

  Future<void> _connectToWifi(WifiNetwork network) async {
    setState(() {
      _isConnecting = true;
    });
    String? password = await _showPasswordDialog();
    if (password != null) {
      bool isConnected = await _connectWithPassword(network, password);
      if (isConnected) {
        String? ipAddress = await WiFiForIoTPlugin.getIP();
        widget.onConnected(network.ssid!, password, ipAddress ?? "Unknown IP");
        Navigator.pop(context);
      }
    }
    setState(() {
      _isConnecting = false;
    });
  }

  Future<bool> _connectWithPassword(
      WifiNetwork network, String password) async {
    try {
      await WiFiForIoTPlugin.connect(network.ssid!,
          password: password, security: NetworkSecurity.WPA);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> _showPasswordDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Password'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, _passwordController.text);
                _passwordController.clear();
              },
              child: Text('Connect'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WiFi Networks'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _scanWifiNetworks,
          ),
        ],
      ),
      body: _isScanning || _isConnecting
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _networks.length,
              itemBuilder: (context, index) {
                final network = _networks[index];
                return ListTile(
                  title: Text(network.ssid ?? 'Unknown SSID'),
                  subtitle: Text('Signal strength: ${network.level}'),
                  trailing: ElevatedButton(
                    onPressed: () => _connectToWifi(network),
                    child: Text('Connect'),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
