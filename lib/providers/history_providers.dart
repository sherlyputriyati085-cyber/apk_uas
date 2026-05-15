import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_entry.dart';

class HistoryNotifier extends Notifier<List<HistoryEntry>> {
  @override
  List<HistoryEntry> build() {
    return [];
  }

  void addEntry(String title, String foodName, IconData icon, Color color) {
    state = [
      HistoryEntry(
        id: DateTime.now().toString(),
        title: title,
        foodName: foodName,
        timestamp: DateTime.now(),
        icon: icon,
        color: color,
      ),
      ...state,
    ];
  }

  void clearHistory() {
    state = [];
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<HistoryEntry>>(
  HistoryNotifier.new,
);
