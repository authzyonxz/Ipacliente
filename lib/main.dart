import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxy iOS Advanced',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        primaryColor: const Color(0xFF9C27B0),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9C27B0),
          secondary: Color(0xFF7B1FA2),
          surface: Color(0xFF1E1E1E),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final udid = prefs.getString('udid');
    final key = prefs.getString('key');

    if (udid != null && key != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(autoUdid: udid, autoKey: key),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SpinKitPulse(color: Color(0xFF9C27B0), size: 80.0),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final String? autoUdid;
  final String? autoKey;
  const LoginPage({Key? key, this.autoUdid, this.autoKey}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _udidController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  bool _isLoading = false;
  final String apiUrl = 'http://179.198.97.250:5000';

  @override
  void initState() {
    super.initState();
    if (widget.autoUdid != null) _udidController.text = widget.autoUdid!;
    if (widget.autoKey != null) _keyController.text = widget.autoKey!;
    
    if (widget.autoUdid != null && widget.autoKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _login());
    }
  }

  Future<void> _login() async {
    if (_udidController.text.isEmpty || _keyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/client/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'udid': _udidController.text.trim(),
          'key': _keyController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('udid', _udidController.text.trim());
        await prefs.setString('key', _keyController.text.trim());

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              udid: _udidController.text.trim(),
              licenseKey: _keyController.text.trim(),
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
        const SnackBar(content: Text('Erro de conexão: Verifique sua internet')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A0033), Color(0xFF0F0F0F)],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.security, size: 80, color: Color(0xFF9C27B0)),
                  const SizedBox(height: 20),
                  const Text(
                    'PROXY IOS ADVANCED',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'PREMIUM EDITION',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9C27B0), letterSpacing: 4),
                  ),
                  const SizedBox(height: 50),
                  _buildTextField(_udidController, 'DISPOSITIVO UDID', Icons.phone_iphone),
                  const SizedBox(height: 20),
                  _buildTextField(_keyController, 'CHAVE DE ACESSO', Icons.vpn_key),
                  const SizedBox(height: 40),
                  _isLoading
                      ? Column(
                          children: [
                            const SpinKitThreeBounce(color: Color(0xFF9C27B0), size: 30),
                            const SizedBox(height: 10),
                            const Text('CONECTANDO AO SERVIDOR...', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9C27B0),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 10,
                          ),
                          child: const Text(
                            'AUTENTICAR AGORA',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFF9C27B0)),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF9C27B0), width: 1),
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
        title: const Text('PROXY IOS ADVANCED', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A0033),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          )
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ServersTab(vpsIp: '179.198.97.250'),
          ProfileTab(udid: widget.udid, licenseKey: widget.licenseKey),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF1E1E1E), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: const Color(0xFF0F0F0F),
          selectedItemColor: const Color(0xFF9C27B0),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'SERVIDORES'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'MINHA CONTA'),
          ],
        ),
      ),
    );
  }
}

class ServersTab extends StatelessWidget {
  final String vpsIp;
  const ServersTab({Key? key, required this.vpsIp}) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> ports = [
      {'port': '9999', 'desc': 'HS ALTO + PESCOÇO SEM ANTENA', 'type': 'Agressivo'},
      {'port': '9998', 'desc': 'HS ALTO + PESCOÇO COM ANTENA', 'type': 'Agressivo'},
      {'port': '9997', 'desc': 'HS QUADRIL 80 + ANTENA', 'type': 'Legit'},
      {'port': '9996', 'desc': 'BALA MAGICA (EXPERIMENTAL)', 'type': 'Risk'},
      {'port': '8080', 'desc': 'BURLADOR DE HISTORICO (BYPASS)', 'type': 'Safe'},
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF4A00E0)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Text('STATUS DO SERVIDOR', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 5),
              const Text('ONLINE', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('IP: $vpsIp', style: const TextStyle(color: Colors.white60, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Text('CONFIGURAÇÕES DISPONÍVEIS', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 15),
        ...ports.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                title: Row(
                  children: [
                    Text('PORTA ${p['port']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getTypeColor(p['type']!),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(p['type']!, style: const TextStyle(fontSize: 10, color: Colors.white)),
                    )
                  ],
                ),
                subtitle: Text(p['desc']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.download_for_offline, color: Color(0xFF9C27B0), size: 30),
                  onPressed: () => _launchURL('http://$vpsIp:5000/static/downloads/proxy_${p['port']}.mobileconfig'),
                ),
              ),
            )),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Agressivo': return Colors.redAccent;
      case 'Legit': return Colors.greenAccent;
      case 'Safe': return Colors.blueAccent;
      default: return Colors.orangeAccent;
    }
  }
}

class ProfileTab extends StatefulWidget {
  final String udid;
  final String licenseKey;

  const ProfileTab({Key? key, required this.udid, required this.licenseKey})
      : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _expiryDate = "Carregando...";
  String _status = "Verificando...";

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    try {
      final response = await http.post(
        Uri.parse('http://179.198.97.250:5000/client/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'udid': widget.udid, 'key': widget.licenseKey}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final date = DateTime.parse(data['expiry_date']);
          _expiryDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
          _status = data['key_status'].toString().toUpperCase();
        });
      }
    } catch (e) {
      setState(() {
        _expiryDate = "Erro ao carregar";
        _status = "OFFLINE";
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoCard('IDENTIFICAÇÃO UDID', widget.udid, Icons.fingerprint),
        _buildInfoCard('CHAVE ATIVA', widget.licenseKey, Icons.key),
        _buildInfoCard('VALIDADE ATÉ', _expiryDate, Icons.event_available, valueColor: const Color(0xFF9C27B0)),
        _buildInfoCard('STATUS DA LICENÇA', _status, Icons.info_outline, valueColor: _status == 'ACTIVE' ? Colors.green : Colors.red),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: () => _launchURL('http://179.198.97.250:5000/static/downloads/mitmproxy-ca-cert.pem'),
          icon: const Icon(Icons.verified_user),
          label: const Text('BAIXAR CERTIFICADO HTTPS'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E1E1E),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: Color(0xFF9C27B0), width: 1),
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'DICA: Após baixar o certificado, vá em Ajustes > Geral > Sobre > Ajustes de Confiança do Certificado e ative o MitmProxy.',
          style: TextStyle(color: Colors.grey, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, {Color? valueColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9C27B0), size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
