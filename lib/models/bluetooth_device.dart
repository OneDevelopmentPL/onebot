class SavedBluetoothDevice {
  final String name;
  final String address;
  final DateTime lastConnected;

  SavedBluetoothDevice({
    required this.name,
    required this.address,
    required this.lastConnected,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'lastConnected': lastConnected.toIso8601String(),
    };
  }

  factory SavedBluetoothDevice.fromJson(Map<String, dynamic> json) {
    return SavedBluetoothDevice(
      name: json['name'] as String,
      address: json['address'] as String,
      lastConnected: DateTime.parse(json['lastConnected'] as String),
    );
  }
}
