import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FW Tool',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
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
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // =============================
  // CONVERSÃO
  // =============================
  String hexToFwVersion(String hexValue) {
    hexValue = hexValue.trim().toUpperCase();

    if (hexValue.length != 4) {
      throw Exception("Deve conter 4 caracteres HEX.");
    }

    final isValid = RegExp(r'^[0-9A-F]+$').hasMatch(hexValue);
    if (!isValid) {
      throw Exception("HEX inválido.");
    }

    final byte1 = hexValue.substring(0, 2);
    final byte2 = hexValue.substring(2, 4);

    final dec1 = int.parse(byte1, radix: 16);
    final dec2 = int.parse(byte2, radix: 16);

    return "R01A${dec1.toString().padLeft(2, '0')}V${dec2.toString().padLeft(2, '0')}";
  }

  // =============================
  // HISTÓRICO (PERSISTENTE)
  // =============================
  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history', _history);
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('history') ?? [];
    });
  }

  void addToHistory(String entry) {
    setState(() {
      _history.insert(0, entry);
    });
    saveHistory();
  }

  void clearHistory() {
    setState(() {
      _history.clear();
    });
    saveHistory();
  }

  // =============================
  // AÇÕES
  // =============================
  void convert() {
    try {
      final result = hexToFwVersion(_controller.text);

      setState(() {
        _result = result;
      });

      addToHistory("${_controller.text.toUpperCase()} → $result");
    } catch (e) {
      setState(() {
        _result = "Erro: $e";
      });
    }
  }

  void copyResult() {
    if (_result.isEmpty || _result.startsWith("Erro")) return;

    Clipboard.setData(ClipboardData(text: _result));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Copiado!")));
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FW Converter Tool"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: clearHistory,
            tooltip: "Limpar histórico",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // INPUT CARD
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: "HEX Firmware",
                        hintText: "Ex: 0916",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: convert,
                            icon: const Icon(Icons.settings),
                            label: const Text("Converter"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: copyResult,
                          icon: const Icon(Icons.copy),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // RESULTADO CARD
            Card(
              elevation: 2,
              child: ListTile(
                title: const Text("Resultado"),
                subtitle: Text(
                  _result.isEmpty ? "—" : _result,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // HISTÓRICO
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Histórico",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _history.isEmpty
                  ? const Center(child: Text("Sem histórico"))
                  : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(_history[index]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
