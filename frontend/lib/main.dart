import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABHAYA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TemplatePage(),
    );
  }
}

class TemplatePage extends StatefulWidget {
  const TemplatePage({super.key});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  String _backendStatus = "Not Tested";

  Future<void> _testBackendWiring() async {
    setState(() {
      _backendStatus = "Testing...";
    });

    try {
      // 10.0.2.2 is used to access localhost from the Android emulator. 
      // Change to localhost or 127.0.0.1 for web/windows.
      final response = await http.get(Uri.parse('http://127.0.0.1:3000/api/health'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _backendStatus = "Success: ${data['message'] ?? 'Connected!'}";
        });
      } else {
        setState(() {
          _backendStatus = "Error: Status Code ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _backendStatus = "Connection Failed: Ensure backend is running.\nError: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABHAYA Template'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'This is the ABHAYA frontend template.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _testBackendWiring,
                child: const Text("Test Backend Wiring"),
              ),
              const SizedBox(height: 20),
              Text(
                "Status: $_backendStatus",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: _backendStatus.startsWith("Success") ? Colors.green : (_backendStatus.startsWith("Testing") ? Colors.blue : Colors.red)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
