import 'package:flutter/material.dart';

class CustomButton {
  final String id;
  final String label;
  final String command;
  final Color color;
  final IconData icon;

  CustomButton({
    required this.id,
    required this.label,
    required this.command,
    required this.color,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'command': command,
      'color': color.value,
      'icon': icon.codePoint,
    };
  }

  factory CustomButton.fromJson(Map<String, dynamic> json) {
    return CustomButton(
      id: json['id'] as String,
      label: json['label'] as String,
      command: json['command'] as String,
      color: Color(json['color'] as int),
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
    );
  }
}
