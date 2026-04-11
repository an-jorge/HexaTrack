import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FW Converter',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';

  String hexToFwVersion(String hexValue) {
    hexValue = hexValue.trim().toUpperCase();

    if (hexValue.length != 4) {
      throw Exception("Deve conter 4 caracteres HEX.");
    }

    // valida HEX
    final isValid = RegExp(r'^[0-9A-F]+$').hasMatch(hexValue);
    if (!isValid) {
      throw Exception("Valor inválido (use 0-9, A-F).");
    }

    final byte1 = hexValue.substring(0, 2);
    final byte2 = hexValue.substring(2, 4);

    final dec1 = int.parse(byte1, radix: 16);
    final dec2 = int.parse(byte2, radix: 16);

    return "R01A${dec1.toString().padLeft(2, '0')}V${dec2.toString().padLeft(2, '0')}";
  }

  void convert() {
    try {
      final result = hexToFwVersion(_controller.text);
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _result = "Erro: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Conversor FW")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "HEX (ex: 0916)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: convert, child: const Text("Converter")),
            const SizedBox(height: 20),
            Text(
              _result,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
