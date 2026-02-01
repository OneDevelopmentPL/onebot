import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import '../services/storage_service.dart';
import '../models/custom_button.dart';
import 'add_button_screen.dart';

class ControlScreen extends StatefulWidget {
  final String deviceName;
  final BluetoothService bluetoothService;

  const ControlScreen({
    super.key,
    required this.deviceName,
    required this.bluetoothService,
  });

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final StorageService _storageService = StorageService();
  List<CustomButton> _customButtons = [];
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadCustomButtons();
    
    // Słuchaj stanu połączenia
    widget.bluetoothService.connectionState.listen((connected) {
      if (mounted) {
        setState(() {
          _isConnected = connected;
        });
        
        if (!connected) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Połączenie utracone')),
          );
          Navigator.pop(context);
        }
      }
    });
    
    _isConnected = widget.bluetoothService.isConnected;
  }

  Future<void> _loadCustomButtons() async {
    final buttons = await _storageService.getCustomButtons();
    setState(() {
      _customButtons = buttons;
    });
  }

  Future<void> _sendCommand(String command, String label) async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brak połączenia')),
      );
      return;
    }

    final success = await widget.bluetoothService.sendCommand(command);
    
    if (success) {
      // Krótka informacja zwrotna
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(label),
          duration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd wysyłania komendy')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sterowanie'),
            Text(
              widget.deviceName,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Status połączenia
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.greenAccent : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Przycisk dodawania własnych przycisków
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddButtonScreen(),
                ),
              );
              _loadCustomButtons();
            },
            tooltip: 'Dodaj własny przycisk',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Główne przyciski sterowania
            const Text(
              'Sterowanie podstawowe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Strzałka do przodu
            _buildControlButton(
              icon: Icons.arrow_upward,
              label: 'Do przodu',
              command: 'F',
              color: Colors.blue,
            ),
            
            const SizedBox(height: 8),
            
            // Lewo i prawo
            Row(
              children: [
                Expanded(
                  child: _buildControlButton(
                    icon: Icons.arrow_back,
                    label: 'W lewo',
                    command: 'L',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildControlButton(
                    icon: Icons.arrow_forward,
                    label: 'W prawo',
                    command: 'R',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Strzałka do tyłu
            _buildControlButton(
              icon: Icons.arrow_downward,
              label: 'Do tyłu',
              command: 'B',
              color: Colors.red,
            ),
            
            // Własne przyciski
            if (_customButtons.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text(
                'Własne przyciski',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2,
                ),
                itemCount: _customButtons.length,
                itemBuilder: (context, index) {
                  final button = _customButtons[index];
                  return _buildCustomButton(button);
                },
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Przycisk rozłączenia
            OutlinedButton.icon(
              onPressed: () async {
                await widget.bluetoothService.disconnect();
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.bluetooth_disabled),
              label: const Text('Rozłącz'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required String command,
    required Color color,
  }) {
    return GestureDetector(
      onTapDown: (_) => _sendCommand(command, label),
      onTapUp: (_) => _sendCommand('S', 'Stop'),
      onTapCancel: () => _sendCommand('S', 'Stop'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton(CustomButton button) {
    return ElevatedButton(
      onPressed: () => _sendCommand(button.command, button.label),
      onLongPress: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Usuń przycisk'),
            content: Text('Czy na pewno chcesz usunąć przycisk "${button.label}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Anuluj'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Usuń'),
              ),
            ],
          ),
        );
        
        if (confirm == true) {
          await _storageService.removeCustomButton(button.id);
          _loadCustomButtons();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: button.color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(button.icon, size: 24),
          const SizedBox(height: 4),
          Text(
            button.label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}