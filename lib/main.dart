import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
    return [];
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

class UserProfile {
  final String name;
  final String email;
  final String? imagePath;

  UserProfile({required this.name, required this.email, this.imagePath});

  UserProfile copyWith({String? name, String? email, String? imagePath}) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    return UserProfile(name: 'User FreshTrack', email: 'user@freshtrack.com');
  }

  void updateProfile({String? name, String? email, String? imagePath}) {
    state = state.copyWith(name: name, email: email, imagePath: imagePath);
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(
  UserProfileNotifier.new,
);

// --- UI SCREENS ---

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E9), Colors.white, Color(0xFFC8E6C9)],
          ),
        ),
        child: Stack(
          children: [
            // Decorative shapes
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ).animate().scale(duration: 2.seconds, curve: Curves.easeInOut),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.leaf,
                        size: 80,
                        color: Color(0xFF4CAF50),
                      ),
                    )
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.easeOutBack)
                    .fadeIn(),
                const SizedBox(height: 32),
                Text(
                  'FreshTrack',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B5E20),
                    letterSpacing: -1,
                  ),
                ).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),
                Text(
                  'Food Expiry Tracker',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    color: Colors.grey[700],
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 600.ms),
                const Spacer(),
                const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                ).animate().fadeIn(delay: 1000.ms),
                const SizedBox(height: 80),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const HistoryScreen(),
    const AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.layoutGrid),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddFoodScreen()),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
