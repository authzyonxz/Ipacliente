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
        primarySwatch: Colors.blue,
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
  String _statusMessage = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Aguardando resposta do servidor...';
    });

    try {
      final udid = _udidController.text;
      final key = _keyController.text;

      if (udid.isEmpty || key.isEmpty) {
        setState(() {
          _statusMessage = 'UDID e Chave são obrigatórios';
          _isLoading = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse('http://179.198.97.250:5000/client/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'udid': udid, 'key': key}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomePage(udid: udid, key: key),
              ),
            );
          }
        } else {
          setState(() {
            _statusMessage = 'Erro: ${data['message']}';
          });
        }
      } else {
        setState(() {
          _statusMessage = 'Erro: Chave ou UDID inválido';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro de conexão: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nitro Proxy Client'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Login',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _udidController,
              decoration: InputDecoration(
                labelText: 'UDID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.phone_iphone),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _keyController,
              decoration: InputDecoration(
                labelText: 'Chave (XXXX-XXXX-XXXX)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.vpn_key),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Entrar'),
            ),
            const SizedBox(height: 16),
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('Erro')
                      ? Colors.red.shade100
                      : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('Erro')
                        ? Colors.red.shade700
                        : Colors.blue.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _udidController.dispose();
    _keyController.dispose();
    super.dispose();
  }
}

class HomePage extends StatefulWidget {
  final String udid;
  final String key;

  const HomePage({Key? key, required this.udid, required this.key})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nitro Proxy'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _selectedTabIndex == 0
          ? const ServersTab(vpsIp: '179.198.97.250')
          : ProfileTab(udid: widget.udid, key: widget.key),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dns),
            label: 'Servidores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class ServersTab extends StatefulWidget {
  final String vpsIp;

  const ServersTab({Key? key, required this.vpsIp}) : super(key: key);

  @override
  State<ServersTab> createState() => _ServersTabState();
}

class _ServersTabState extends State<ServersTab> {
  final List<Map<String, String>> servers = [
    {
      'port': '9999',
      'name': 'HS ALTO + PESCOÇO SEM ANTENA',
      'description': 'Drag Only',
    },
    {
      'port': '9998',
      'name': 'HS ALTO + PESCOÇO COM ANTENA',
      'description': 'Antenna',
    },
    {
      'port': '9997',
      'name': 'HS QUADRIL 80 + ANTENA',
      'description': 'Magic Bullet',
    },
    {
      'port': '9996',
      'name': 'BALA MAGICA',
      'description': 'Body 90%',
    },
    {
      'port': '8080',
      'name': 'BURLADOR DE HISTORICO DE LOGIN',
      'description': 'Bypass',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'IP da VPS:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.vpsIp,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: servers.length,
            itemBuilder: (context, index) {
              final server = servers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(server['name']!),
                  subtitle: Text('Porta: ${server['port']} - ${server['description']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Download do MobileConfig para porta ${server['port']}',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProfileTab extends StatefulWidget {
  final String udid;
  final String key;

  const ProfileTab({Key? key, required this.udid, required this.key})
      : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    try {
      final response = await http.post(
        Uri.parse('http://179.198.97.250:5000/client/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'udid': widget.udid, 'key': widget.key}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao carregar perfil');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erro: ${snapshot.error}'),
          );
        }

        final data = snapshot.data ?? {};
        final keyInfo = data['key_info'] ?? {};
        final expiresAt = keyInfo['expires_at'] ?? 0;
        final expiryDate = expiresAt > 0
            ? DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000)
            : null;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informações do Perfil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildInfoCard('UDID', widget.udid),
              const SizedBox(height: 12),
              _buildInfoCard('Chave Vinculada', keyInfo['key'] ?? 'N/A'),
              const SizedBox(height: 12),
              _buildInfoCard(
                'Tempo de Expiração',
                expiryDate != null
                    ? expiryDate.toString().split('.')[0]
                    : 'Sem expiração',
              ),
              const SizedBox(height: 12),
              _buildInfoCard('Status', keyInfo['status'] ?? 'N/A'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Certificado baixado')),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Baixar Certificado'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
