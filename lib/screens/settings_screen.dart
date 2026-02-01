import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  bool _autoReconnect = true;
  bool _showNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _autoReconnect = prefs.getBool('auto_reconnect') ?? true;
      _showNotifications = prefs.getBool('show_notifications') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          
          // Sekcja: Sterowanie
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'STEROWANIE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          
          SwitchListTile(
            title: const Text('Wibracje'),
            subtitle: const Text('Wibruj przy naciśnięciu przycisku'),
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() => _vibrationEnabled = value);
              _saveSetting('vibration_enabled', value);
            },
            secondary: const Icon(Icons.vibration),
          ),
          
          SwitchListTile(
            title: const Text('Dźwięki'),
            subtitle: const Text('Odtwarzaj dźwięk przy akcjach'),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
              _saveSetting('sound_enabled', value);
            },
            secondary: const Icon(Icons.volume_up),
          ),
          
          const Divider(),
          
          // Sekcja: Połączenie
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'POŁĄCZENIE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          
          SwitchListTile(
            title: const Text('Auto-reconnect'),
            subtitle: const Text('Automatycznie łącz po utracie połączenia'),
            value: _autoReconnect,
            onChanged: (value) {
              setState(() => _autoReconnect = value);
              _saveSetting('auto_reconnect', value);
            },
            secondary: const Icon(Icons.sync),
          ),
          
          SwitchListTile(
            title: const Text('Powiadomienia'),
            subtitle: const Text('Pokazuj powiadomienia o statusie'),
            value: _showNotifications,
            onChanged: (value) {
              setState(() => _showNotifications = value);
              _saveSetting('show_notifications', value);
            },
            secondary: const Icon(Icons.notifications),
          ),
          
          const Divider(),
          
          // Sekcja: Informacje
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'INFORMACJE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Wersja aplikacji'),
            subtitle: const Text('1.0.0'),
            onTap: () {},
          ),
          
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('O aplikacji'),
            subtitle: const Text('OneBot - Sterowanie robotem przez Bluetooth'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'OneBot',
                applicationVersion: '1.0.0',
                applicationIcon: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                children: const [
                  Text('Aplikacja do sterowania robotem przez Bluetooth HC-06.'),
                  SizedBox(height: 10),
                  Text('Obsługiwane komendy: F, B, L, R, S'),
                ],
              );
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Pomoc'),
            subtitle: const Text('Jak używać aplikacji'),
            onTap: () {
              _showHelpDialog();
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pomoc'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Jak podłączyć robota:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Sparuj HC-06 w ustawieniach Bluetooth'),
              Text('2. Kliknij "+" w aplikacji'),
              Text('3. Wybierz urządzenie z listy'),
              Text('4. Poczekaj na połączenie'),
              SizedBox(height: 16),
              Text(
                'Sterowanie:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Przytrzymaj przycisk aby jechać'),
              Text('• Puść aby zatrzymać'),
              Text('• Dodaj własne przyciski przez "+"'),
              SizedBox(height: 16),
              Text(
                'Komendy:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('F - Do przodu'),
              Text('B - Do tyłu'),
              Text('L - W lewo'),
              Text('R - W prawo'),
              Text('S - Stop (automatyczne)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}