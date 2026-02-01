import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bluetooth_device.dart';
import '../models/custom_button.dart';

class StorageService {
  static const String _savedDevicesKey = 'saved_devices';
  static const String _customButtonsKey = 'custom_buttons';

  // Zapisywanie urządzeń
  Future<void> saveDevice(SavedBluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    final devices = await getSavedDevices();
    
    // Usuń stare wpisy tego samego urządzenia
    devices.removeWhere((d) => d.address == device.address);
    
    // Dodaj nowe urządzenie
    devices.add(device);
    
    // Zapisz
    final devicesJson = devices.map((d) => d.toJson()).toList();
    await prefs.setString(_savedDevicesKey, jsonEncode(devicesJson));
  }

  // Pobieranie zapisanych urządzeń
  Future<List<SavedBluetoothDevice>> getSavedDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final devicesString = prefs.getString(_savedDevicesKey);
    
    if (devicesString == null) return [];
    
    final List<dynamic> devicesJson = jsonDecode(devicesString);
    return devicesJson
        .map((json) => SavedBluetoothDevice.fromJson(json))
        .toList()
      ..sort((a, b) => b.lastConnected.compareTo(a.lastConnected));
  }

  // Usuwanie urządzenia
  Future<void> removeDevice(String address) async {
    final prefs = await SharedPreferences.getInstance();
    final devices = await getSavedDevices();
    devices.removeWhere((d) => d.address == address);
    
    final devicesJson = devices.map((d) => d.toJson()).toList();
    await prefs.setString(_savedDevicesKey, jsonEncode(devicesJson));
  }

  // Zapisywanie własnych przycisków
  Future<void> saveCustomButtons(List<CustomButton> buttons) async {
    final prefs = await SharedPreferences.getInstance();
    final buttonsJson = buttons.map((b) => b.toJson()).toList();
    await prefs.setString(_customButtonsKey, jsonEncode(buttonsJson));
  }

  // Pobieranie własnych przycisków
  Future<List<CustomButton>> getCustomButtons() async {
    final prefs = await SharedPreferences.getInstance();
    final buttonsString = prefs.getString(_customButtonsKey);
    
    if (buttonsString == null) return [];
    
    final List<dynamic> buttonsJson = jsonDecode(buttonsString);
    return buttonsJson.map((json) => CustomButton.fromJson(json)).toList();
  }

  // Dodawanie przycisku
  Future<void> addCustomButton(CustomButton button) async {
    final buttons = await getCustomButtons();
    buttons.add(button);
    await saveCustomButtons(buttons);
  }

  // Usuwanie przycisku
  Future<void> removeCustomButton(String id) async {
    final buttons = await getCustomButtons();
    buttons.removeWhere((b) => b.id == id);
    await saveCustomButtons(buttons);
  }
}
