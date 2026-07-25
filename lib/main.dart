import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nitro Proxy Client',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _udidController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  bool _isLoading = false;
  final String apiUrl = 'http://179.198.97.250:5000';

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/client/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'udid': _udidController.text,
          'key': _keyController.text,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success']) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              udid: _udidController.text,
              licenseKey: _keyController.text,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Erro no login')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'NITRO PROXY',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _udidController,
              decoration: const InputDecoration(
                labelText: 'UDID do Dispositivo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(
                labelText: 'Chave de Acesso (Key)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('ENTRAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String udid;
  final String licenseKey;

  const HomePage({Key? key, required this.udid, required this.licenseKey})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nitro Proxy'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ServersTab(vpsIp: '179.198.97.250'),
          ProfileTab(udid: widget.udid, licenseKey: widget.licenseKey),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dns), label: 'Servidores'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class ServersTab extends StatelessWidget {
  final String vpsIp;
  const ServersTab({Key? key, required this.vpsIp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> ports = [
      {'port': '9999', 'desc': 'HS ALTO + PESCOÇO SEM ANTENA'},
      {'port': '9998', 'desc': 'HS ALTO + PESCOÇO COM ANTENA'},
      {'port': '9997', 'desc': 'HS QUADRIL 80 + ANTENA'},
      {'port': '9996', 'desc': 'BALA MAGICA'},
      {'port': '8080', 'desc': 'BURLADOR DE HISTORICO (BYPASS)'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.orange.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('IP DA VPS', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(vpsIp, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...ports.map((p) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('Porta: ${p['port']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(p['desc']!),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Download'),
                ),
              ),
            )),
      ],
    );
  }
}

class ProfileTab extends StatelessWidget {
  final String udid;
  final String licenseKey;

  const ProfileTab({Key? key, required this.udid, required this.licenseKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoTile('UDID', udid),
        _buildInfoTile('KEY VINCULADA', licenseKey),
        _buildInfoTile('EXPIRAÇÃO', 'Calculando...'),
        _buildInfoTile('VERSÃO', '1.0.0'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.verified_user),
          label: const Text('BAIXAR CERTIFICADO'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
        ],
      ),
    );
  }
}
