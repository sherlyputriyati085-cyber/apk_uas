import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_entry.dart';
import '../database/database_helper.dart';

class HistoryNotifier extends Notifier<List<HistoryEntry>> {
  @override
  List<HistoryEntry> build() {
    _loadHistory();
    return [];
  }

  Future<void> _loadHistory() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final historyMaps = await dbHelper.getHistory();
      state = historyMaps.map((map) => HistoryEntry.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  Future<void> addEntry(String title, String foodName, IconData icon, Color color) async {
    final entry = HistoryEntry(
      id: DateTime.now().toString(),
      title: title,
      foodName: foodName,
      timestamp: DateTime.now(),
      icon: icon,
      color: color,
    );

    try {
      await DatabaseHelper.instance.insertHistory(entry.toMap());
      state = [entry, ...state];
    } catch (e) {
      debugPrint('Error adding history entry: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      await DatabaseHelper.instance.clearHistory();
      state = [];
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<HistoryEntry>>(
  HistoryNotifier.new,
);
