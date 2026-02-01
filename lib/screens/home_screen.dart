import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../services/bluetooth_service.dart';
import '../services/storage_service.dart';
import '../models/bluetooth_device.dart';
import 'control_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final BluetoothService _bluetoothService = BluetoothService();
  final StorageService _storageService = StorageService();
  
  late TabController _tabController;
  
  List<SavedBluetoothDevice> _savedDevices = [];
  List<BluetoothDevice> _hc06Devices = [];
  List<BluetoothDevice> _otherDevices = [];
  final List<BluetoothDiscoveryResult> _discoveryResults = [];
  
  bool _isScanning = false;
  bool _isBluetoothEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initialize();
  }

  Future<void> _initialize() async {
    // Sprawdź uprawnienia
    final hasPermissions = await _bluetoothService.requestPermissions();
    if (!hasPermissions) {
      _showPermissionDialog();
      return;
    }

    // Sprawdź Bluetooth
    _isBluetoothEnabled = await _bluetoothService.isBluetoothEnabled();
    if (!_isBluetoothEnabled) {
      await _bluetoothService.enableBluetooth();
      _isBluetoothEnabled = await _bluetoothService.isBluetoothEnabled();
    }

    // Załaduj zapisane urządzenia
    _loadSavedDevices();
    
    // Załaduj sparowane urządzenia
    _loadDevices();
  }

  Future<void> _loadSavedDevices() async {
    final devices = await _storageService.getSavedDevices();
    setState(() {
      _savedDevices = devices;
    });
  }

  Future<void> _loadDevices() async {
    final devices = await _bluetoothService.getDevices();
    
    setState(() {
      _hc06Devices = devices.where((d) => 
        d.name?.toUpperCase().contains('HC-06') ?? false
      ).toList();
      
      _otherDevices = devices.where((d) => 
        !(d.name?.toUpperCase().contains('HC-06') ?? false)
      ).toList();
    });
  }

  Future<void> _startDiscovery() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _discoveryResults.clear();
    });

    _bluetoothService.startDiscovery().listen((result) {
      setState(() {
        final existingIndex = _discoveryResults.indexWhere(
          (r) => r.device.address == result.device.address
        );
        
        if (existingIndex >= 0) {
          _discoveryResults[existingIndex] = result;
        } else {
          _discoveryResults.add(result);
        }
      });
    }).onDone(() {
      setState(() {
        _isScanning = false;
      });
      _loadDevices();
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await _bluetoothService.connect(device.address);
    
    if (mounted) {
      Navigator.pop(context);
      
      if (success) {
        // Zapisz urządzenie
        await _storageService.saveDevice(SavedBluetoothDevice(
          name: device.name ?? 'Nieznane',
          address: device.address,
          lastConnected: DateTime.now(),
        ));
        
        // Przejdź do ekranu sterowania
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ControlScreen(
              deviceName: device.name ?? 'Nieznane',
              bluetoothService: _bluetoothService,
            ),
          ),
        ).then((_) => _loadSavedDevices());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nie udało się połączyć')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OneBot'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'HC-06'),
            Tab(text: 'Inne'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Ustawienia',
          ),
          IconButton(
            icon: _isScanning 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.add),
            onPressed: _isScanning ? null : _startDiscovery,
            tooltip: 'Wyszukaj urządzenia',
          ),
        ],
      ),
      body: !_isBluetoothEnabled
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bluetooth_disabled, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Bluetooth jest wyłączony'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _bluetoothService.enableBluetooth();
                    _initialize();
                  },
                  child: const Text('Włącz Bluetooth'),
                ),
              ],
            ),
          )
        : TabBarView(
            controller: _tabController,
            children: [
              _buildDevicesList(_hc06Devices, true),
              _buildDevicesList(_otherDevices, false),
            ],
          ),
    );
  }

  Widget _buildDevicesList(List<BluetoothDevice> devices, bool isHC06Tab) {
    final discoveryDevices = _discoveryResults
        .where((r) => isHC06Tab 
          ? (r.device.name?.toUpperCase().contains('HC-06') ?? false)
          : !(r.device.name?.toUpperCase().contains('HC-06') ?? false))
        .toList();

    return RefreshIndicator(
      onRefresh: _loadDevices,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          // Zapisane urządzenia
          if (_savedDevices.isNotEmpty && isHC06Tab) ...[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Ostatnio używane',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ..._savedDevices.map((device) => _buildSavedDeviceCard(device)),
            const Divider(height: 32),
          ],
          
          // Sparowane urządzenia
          if (devices.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Sparowane urządzenia',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ...devices.map((device) => _buildDeviceCard(device)),
          ],
          
          // Wykryte urządzenia
          if (discoveryDevices.isNotEmpty) ...[
            const Divider(height: 32),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Wykryte urządzenia',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ...discoveryDevices.map((result) => _buildDiscoveryCard(result)),
          ],
          
          // Pusty stan
          if (devices.isEmpty && discoveryDevices.isEmpty && 
              (_savedDevices.isEmpty || !isHC06Tab)) ...[
            const SizedBox(height: 100),
            Center(
              child: Column(
                children: [
                  Icon(
                    isHC06Tab ? Icons.bluetooth_searching : Icons.devices_other,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isHC06Tab 
                      ? 'Brak urządzeń HC-06'
                      : 'Brak innych urządzeń',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _startDiscovery,
                    icon: const Icon(Icons.search),
                    label: const Text('Wyszukaj urządzenia'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSavedDeviceCard(SavedBluetoothDevice device) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.bluetooth, color: Colors.white),
        ),
        title: Text(device.name),
        subtitle: Text(device.address),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await _storageService.removeDevice(device.address);
                _loadSavedDevices();
              },
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          final bluetoothDevice = BluetoothDevice(
            name: device.name,
            address: device.address,
          );
          _connectToDevice(bluetoothDevice);
        },
      ),
    );
  }

  Widget _buildDeviceCard(BluetoothDevice device) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(
            device.isBonded ? Icons.link : Icons.bluetooth,
            color: Colors.white,
          ),
        ),
        title: Text(device.name ?? 'Nieznane urządzenie'),
        subtitle: Text(device.address),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _connectToDevice(device),
      ),
    );
  }

  Widget _buildDiscoveryCard(BluetoothDiscoveryResult result) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(
            Icons.bluetooth_searching,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(result.device.name ?? 'Nieznane urządzenie'),
        subtitle: Text(
          '${result.device.address} • RSSI: ${result.rssi}'
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _connectToDevice(result.device),
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wymagane uprawnienia'),
        content: const Text(
          'Aplikacja wymaga uprawnień Bluetooth i lokalizacji do działania.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _initialize();
            },
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bluetoothService.dispose();
    super.dispose();
  }
}