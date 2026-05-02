import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const ProviderScope(child: FreshTrackApp()));
}

class FreshTrackApp extends StatelessWidget {
  const FreshTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFF8BC34A),
          surface: Colors.white,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF8FAF8),
      ),
      home: const SplashScreen(),
    );
  }
}

// --- MODELS ---

enum FoodStatus { aman, hampir, expired }

class FoodItem {
  final String id;
  final String name;
  final String category;
  final DateTime expiryDate;
  final String? notes;
  final String? imagePath;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.expiryDate,
    this.notes,
    this.imagePath,
  });

  FoodStatus get status {
    final now = DateTime.now();
    final difference = expiryDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (difference < 0) return FoodStatus.expired;
    if (difference <= 7) return FoodStatus.hampir;
    return FoodStatus.aman;
  }

  int get daysLeft {
    final now = DateTime.now();
    return expiryDate.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  FoodItem copyWith({
    String? name,
    String? category,
    DateTime? expiryDate,
    String? notes,
    String? imagePath,
  }) {
    return FoodItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'expiryDate': expiryDate.toIso8601String(),
      'notes': notes,
      'imagePath': imagePath,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      expiryDate: DateTime.parse(map['expiryDate']),
      notes: map['notes'],
      imagePath: map['imagePath'],
    );
  }
}

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
      'color': color.value,
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

// --- STATE MANAGEMENT ---

class FoodNotifier extends Notifier<List<FoodItem>> {
  @override
  List<FoodItem> build() {
    return [
      FoodItem(
        id: '1',
        name: 'Susu UHT',
        category: 'Minuman',
        expiryDate: DateTime.now().add(const Duration(days: 27)),
        notes: 'Simpan di kulkas setelah dibuka',
      ),
      FoodItem(
        id: '2',
        name: 'Roti Tawar',
        category: 'Makanan Instan',
        expiryDate: DateTime.now().add(const Duration(days: 4)),
        notes: 'Habiskan segera',
      ),
      FoodItem(
        id: '3',
        name: 'Telur',
        category: 'Daging',
        expiryDate: DateTime.now().add(const Duration(days: 10)),
      ),
      FoodItem(
        id: '4',
        name: 'Daging Ayam',
        category: 'Daging',
        expiryDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  void addFood(FoodItem food) {
    state = [...state, food];
  }

  void updateFood(FoodItem updatedFood) {
    state = [
      for (final food in state)
        if (food.id == updatedFood.id) updatedFood else food,
    ];
  }

  void deleteFood(String id) {
    state = state.where((f) => f.id != id).toList();
  }
}

final foodProvider = NotifierProvider<FoodNotifier, List<FoodItem>>(
  FoodNotifier.new,
);

class HistoryNotifier extends Notifier<List<HistoryEntry>> {
  @override
  List<HistoryEntry> build() {
    return [
      HistoryEntry(
        id: '1',
        title: 'Menambahkan',
        foodName: 'Susu UHT',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        icon: LucideIcons.plus,
        color: Colors.green,
      ),
      HistoryEntry(
        id: '2',
        title: 'Mengedit',
        foodName: 'Telur',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        icon: LucideIcons.edit2,
        color: Colors.orange,
      ),
      HistoryEntry(
        id: '3',
        title: 'Menghapus',
        foodName: 'Daging Sapi',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        icon: LucideIcons.trash2,
        color: Colors.red,
      ),
    ];
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
}

final historyProvider = NotifierProvider<HistoryNotifier, List<HistoryEntry>>(
  HistoryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final filteredFoodProvider = Provider<List<FoodItem>>((ref) {
  final foods = ref.watch(foodProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return foods;
  return foods.where((f) => f.name.toLowerCase().contains(query)).toList();
});
