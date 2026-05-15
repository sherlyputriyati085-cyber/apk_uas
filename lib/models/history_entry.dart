import 'package:flutter/material.dart';

class HistoryEntry {
  final String id;
  final String title;
  final String foodName;
  final DateTime timestamp;
  final IconData icon;
  final Color color;

  HistoryEntry({
    required this.id,
    required this.title,
    required this.foodName,
    required this.timestamp,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'foodName': foodName,
      'timestamp': timestamp.toIso8601String(),
      'icon': icon.codePoint,
      'color': color.toARGB32(),
    };
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map['id'],
      title: map['title'],
      foodName: map['foodName'],
      timestamp: DateTime.parse(map['timestamp']),
      icon: IconData(
        map['icon'],
        fontFamily: 'LucideIcons',
        fontPackage: 'lucide_icons',
      ),
      color: Color(map['color']),
    );
  }
}
