import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/custom_button.dart';

class AddButtonScreen extends StatefulWidget {
  const AddButtonScreen({super.key});

  @override
  State<AddButtonScreen> createState() => _AddButtonScreenState();
}

class _AddButtonScreenState extends State<AddButtonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _commandController = TextEditingController();
  final StorageService _storageService = StorageService();
  
  Color _selectedColor = Colors.purple;
  IconData _selectedIcon = Icons.settings_remote;

  final List<Color> _availableColors = [
    Colors.purple,
    Colors.green,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
  ];

  final List<IconData> _availableIcons = [
    Icons.settings_remote,
    Icons.speed,
    Icons.stop,
    Icons.pause,
    Icons.play_arrow,
    Icons.rotate_left,
    Icons.rotate_right,
    Icons.light_mode,
    Icons.music_note,
    Icons.volume_up,
    Icons.flash_on,
    Icons.power_settings_new,
    Icons.favorite,
    Icons.star,
    Icons.camera,
    Icons.radio_button_checked,
  ];

  Future<void> _saveButton() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final button = CustomButton(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: _labelController.text,
      command: _commandController.text,
      color: _selectedColor,
      icon: _selectedIcon,
    );

    await _storageService.addCustomButton(button);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Przycisk został dodany')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj własny przycisk'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Podgląd przycisku
            Card(
              elevation: 4,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedIcon,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _labelController.text.isEmpty 
                          ? 'Podgląd' 
                          : _labelController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Nazwa przycisku
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Nazwa przycisku',
                hintText: 'np. Turbo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Podaj nazwę przycisku';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            
            const SizedBox(height: 16),
            
            // Komenda
            TextFormField(
              controller: _commandController,
              decoration: const InputDecoration(
                labelText: 'Komenda',
                hintText: 'np. T',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.code),
                helperText: 'Znak lub tekst wysyłany do robota',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Podaj komendę';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Wybór koloru
            const Text(
              'Kolor przycisku',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected 
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Wybór ikony
            const Text(
              'Ikona przycisku',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected ? _selectedColor : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // Przycisk zapisu
            ElevatedButton.icon(
              onPressed: _saveButton,
              icon: const Icon(Icons.save),
              label: const Text('Zapisz przycisk'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _commandController.dispose();
    super.dispose();
  }
}
