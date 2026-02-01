import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  BluetoothConnection? _connection;
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  
  StreamSubscription? _connectionSubscription;
  final _connectionStateController = StreamController<bool>.broadcast();
  
  Stream<bool> get connectionState => _connectionStateController.stream;
  bool get isConnected => _connection?.isConnected ?? false;

  // Sprawdzanie i żądanie uprawnień
  Future<bool> requestPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.location.request().isGranted) {
      return true;
    }
    return false;
  }

  // Sprawdzanie czy Bluetooth jest włączony
  Future<bool> isBluetoothEnabled() async {
    return await _bluetooth.isEnabled ?? false;
  }

  // Włączanie Bluetooth
  Future<bool> enableBluetooth() async {
    try {
      await _bluetooth.requestEnable();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Wyszukiwanie urządzeń
  Future<List<BluetoothDevice>> getDevices() async {
    try {
      final bondedDevices = await _bluetooth.getBondedDevices();
      return bondedDevices;
    } catch (e) {
      print('Błąd podczas pobierania urządzeń: $e');
      return [];
    }
  }

  // Skanowanie nowych urządzeń
  Stream<BluetoothDiscoveryResult> startDiscovery() {
    return _bluetooth.startDiscovery();
  }

  // Zatrzymanie skanowania
  Future<void> cancelDiscovery() async {
    await _bluetooth.cancelDiscovery();
  }

  // Połączenie z urządzeniem
  Future<bool> connect(String address) async {
    try {
      if (_connection != null && _connection!.isConnected) {
        await disconnect();
      }

      _connection = await BluetoothConnection.toAddress(address);
      
      _connectionSubscription = _connection!.input!.listen(
        (_) {},
        onDone: () {
          _connectionStateController.add(false);
        },
        onError: (error) {
          _connectionStateController.add(false);
        },
      );

      _connectionStateController.add(true);
      return true;
    } catch (e) {
      print('Błąd połączenia: $e');
      _connectionStateController.add(false);
      return false;
    }
  }

  // Rozłączenie
  Future<void> disconnect() async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
    
    _connectionStateController.add(false);
  }

  // Wysyłanie komendy
  Future<bool> sendCommand(String command) async {
    if (_connection == null || !_connection!.isConnected) {
      return false;
    }

    try {
      _connection!.output.add(Uint8List.fromList(command.codeUnits));
      await _connection!.output.allSent;
      return true;
    } catch (e) {
      print('Błąd wysyłania komendy: $e');
      return false;
    }
  }

  // Czyszczenie zasobów
  void dispose() {
    _connectionSubscription?.cancel();
    _connection?.dispose();
    _connectionStateController.close();
  }
}
