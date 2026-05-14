import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
            Center(
              child: Column(
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
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4CAF50),
                    ),
                  ).animate().fadeIn(delay: 1000.ms),
                  const SizedBox(height: 80),
                ],
              ),
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
      resizeToAvoidBottomInset: false,
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

// --- HOME SCREEN ---

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foods = ref.watch(filteredFoodProvider);
    final allFoods = ref.watch(foodProvider);
    final query = ref.watch(searchQueryProvider);

    final amanCount = allFoods.where((f) => f.status == FoodStatus.aman).length;
    final hampirCount = allFoods
        .where((f) => f.status == FoodStatus.hampir)
        .length;
    final expiredCount = allFoods
        .where((f) => f.status == FoodStatus.expired)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FreshTrack',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ), //text
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                ),
              ),
              if (hampirCount + expiredCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${hampirCount + expiredCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ), // app bar
      body: Stack(
        children: [
          // Background Decorations
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF8BC34A).withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF8FAF8),
                  const Color(0xFFE8F5E9).withValues(alpha: 0.1),
                  const Color(0xFFF8FAF8),
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) =>
                          ref.read(searchQueryProvider.notifier).set(val),
                      decoration: InputDecoration(
                        hintText: 'Cari makanan...',
                        border: InputBorder.none,
                        icon: const Icon(
                          LucideIcons.search,
                          size: 20,
                          color: Colors.grey,
                        ), // icon
                        suffixIcon: ref.watch(searchQueryProvider).isNotEmpty
                            ? IconButton(
                                icon: const Icon(LucideIcons.x, size: 16),
                                onPressed: () {
                                  ref
                                      .read(searchQueryProvider.notifier)
                                      .set('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ringkasan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildSummaryCard(
                        'Aman',
                        amanCount,
                        const Color(0xFFE8F5E9),
                        const Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 12),
                      _buildSummaryCard(
                        'Hampir',
                        hampirCount,
                        const Color(0xFFFFF3E0),
                        const Color(0xFFEF6C00),
                      ),
                      const SizedBox(width: 12),
                      _buildSummaryCard(
                        'Expired',
                        expiredCount,
                        const Color(0xFFFFEBEE),
                        const Color(0xFFC62828),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Makanan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ), // text
                      TextButton(
                        onPressed: () {},
                        child: const Text('Lihat Semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (foods.isEmpty && query.isNotEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Icon(
                            LucideIcons.searchX,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Makanan tidak tersedia',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Coba cari dengan kata kunci lain',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (foods.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          'Belum ada makanan',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: foods.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final food = foods[index];
                        return _buildFoodItemTile(context, food);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    int count,
    Color bgColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ), // text
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemTile(BuildContext context, FoodItem food) {
    Color statusColor;
    String statusLabel;
    switch (food.status) {
      case FoodStatus.aman:
        statusColor = const Color(0xFF4CAF50);
        statusLabel = 'Aman';
        break;
      case FoodStatus.hampir:
        statusColor = const Color(0xFFFF9800);
        statusLabel = 'Hampir';
        break;
      case FoodStatus.expired:
        statusColor = const Color(0xFFF44336);
        statusLabel = 'Expired';
        break;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FoodDetailScreen(food: food)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: food.imagePath != null && food.imagePath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: buildPlatformImage(
                        food.imagePath!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(_getCategoryIcon(food.category), color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Kadaluarsa: ${DateFormat('d MMM yyyy', 'id_ID').format(food.expiryDate)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Minuman':
        return LucideIcons.cupSoda;
      case 'Makanan Instan':
        return LucideIcons.box;
      case 'Buah':
        return LucideIcons.apple;
      case 'Sayuran':
        return LucideIcons.carrot;
      case 'Daging':
        return LucideIcons.drumstick;
      default:
        return LucideIcons.utensils;
    }
  }
}

// --- ADD/EDIT FOOD SCREEN ---

class AddFoodScreen extends ConsumerStatefulWidget {
  final FoodItem? foodToEdit;
  const AddFoodScreen({super.key, this.foodToEdit});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late String _selectedCategory;
  late DateTime _selectedDate;
  String? _imagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.foodToEdit?.name ?? '',
    );
    _notesController = TextEditingController(
      text: widget.foodToEdit?.notes ?? '',
    );
    _selectedCategory = widget.foodToEdit?.category ?? 'Minuman';
    _selectedDate =
        widget.foodToEdit?.expiryDate ??
        DateTime.now().add(const Duration(days: 7));
    _imagePath = widget.foodToEdit?.imagePath;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Sumber Gambar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    icon: LucideIcons.camera,
                    label: 'Kamera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildSourceOption(
                    icon: LucideIcons.image,
                    label: 'Galeri',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.foodToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Makanan' : 'Tambah Makanan'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAF8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          // Background Decorations
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ), // box decoration
            ), // container
          ), // positioned
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF8BC34A).withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ), // box decoration
            ), // container
          ), // position
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo Placeholder
                Center(
                  child: GestureDetector(
                    onTap: () => _showImageSourceActionSheet(context),
                    child: Stack(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                              ),
                            ],
                            image: _imagePath != null
                                ? DecorationImage(
                                    image: FileImage(File(_imagePath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _imagePath == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF4CAF50,
                                        ).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        LucideIcons.camera,
                                        color: Color(0xFF4CAF50),
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Tambah Foto',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              _imagePath == null
                                  ? LucideIcons.plus
                                  : LucideIcons.camera,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildLabel('Nama Makanan'),
                TextField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('Contoh: Susu UHT'),
                ),
                const SizedBox(height: 20),
                _buildLabel('Kategori'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: _buildInputDecoration('Pilih kategori'),
                  items:
                      ['Minuman', 'Makanan Instan', 'Buah', 'Sayuran', 'Daging']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
                const SizedBox(height: 20),
                _buildLabel('Tanggal Kadaluarsa'),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ), //box decoration
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat(
                            'd MMMM yyyy',
                            'id_ID',
                          ).format(_selectedDate), //date format
                        ), // text
                        const Icon(
                          LucideIcons.calendar,
                          size: 20,
                          color: Colors.grey,
                        ), // icon
                      ],
                    ), // row
                  ), // container
                ), //inkwell
                const SizedBox(height: 20),
                _buildLabel('Catatan (opsional)'),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: _buildInputDecoration('Tambahkan catatan...'),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isEmpty) return;

                      if (isEdit) {
                        final updated = widget.foodToEdit!.copyWith(
                          name: _nameController.text,
                          category: _selectedCategory,
                          expiryDate: _selectedDate,
                          notes: _notesController.text,
                          imagePath: _imagePath,
                        );
                        ref.read(foodProvider.notifier).updateFood(updated);
                        ref
                            .read(historyProvider.notifier)
                            .addEntry(
                              'Mengedit',
                              updated.name,
                              LucideIcons.edit2,
                              Colors.orange,
                            );
                      } else {
                        final newItem = FoodItem(
                          id: DateTime.now().toString(),
                          name: _nameController.text,
                          category: _selectedCategory,
                          expiryDate: _selectedDate,
                          notes: _notesController.text,
                          imagePath: _imagePath,
                        ); // food item
                        ref.read(foodProvider.notifier).addFood(newItem);
                        ref
                            .read(historyProvider.notifier)
                            .addEntry(
                              'Menambahkan',
                              newItem.name,
                              LucideIcons.plus,
                              Colors.green,
                            );
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEdit
                                ? 'Berhasil diperbarui'
                                : 'Berhasil ditambahkan',
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEdit ? 'Update' : 'Simpan',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

// --- DETAIL SCREEN ---

class FoodDetailScreen extends ConsumerWidget {
  final FoodItem food;
  const FoodDetailScreen({super.key, required this.food});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor;
    String statusLabel;
    switch (food.status) {
      case FoodStatus.aman:
        statusColor = const Color(0xFF4CAF50);
        statusLabel = 'Aman';
        break;
      case FoodStatus.hampir:
        statusColor = const Color(0xFFFF9800);
        statusLabel = 'Hampir';
        break;
      case FoodStatus.expired:
        statusColor = const Color(0xFFF44336);
        statusLabel = 'Expired';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Makanan'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAF8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          // Background Decorations
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ), // box decoration
            ), //container
          ), // positioned
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    image: food.imagePath != null
                        ? DecorationImage(
                            image: FileImage(File(food.imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ), //boxdecoration
                  child: food.imagePath == null
                      ? Center(
                          child: Icon(
                            LucideIcons.image,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                        )
                      : null,
                ), //container
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            food.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ), //text style
                          ), //text
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ), //text style
                            ), //text
                          ), // container
                        ],
                      ), // row
                      const SizedBox(height: 32),
                      _buildDetailRow(
                        LucideIcons.tag,
                        'Kategori',
                        food.category,
                      ),
                      _buildDetailRow(
                        LucideIcons.calendar,
                        'Tanggal Kadaluarsa',
                        DateFormat(
                          'd MMMM yyyy',
                          'id_ID',
                        ).format(food.expiryDate),
                      ),
                      _buildDetailRow(
                        LucideIcons.clock,
                        'Sisa Waktu',
                        '${food.daysLeft} hari lagi',
                      ),
                      _buildDetailRow(
                        LucideIcons.fileText,
                        'Catatan',
                        food.notes != null && food.notes!.isNotEmpty
                            ? food.notes!
                            : '-',
                      ),
                      const SizedBox(height: 48),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddFoodScreen(foodToEdit: food),
                                ),
                              ),
                              icon: const Icon(LucideIcons.edit2, size: 18),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green,
                                side: const BorderSide(color: Colors.green),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ), // edgeInsets.Symetric
                              ),
                            ), //outlinedbutton.icon
                          ), //expanded
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _confirmDelete(context, ref),
                              icon: const Icon(LucideIcons.trash2, size: 18),
                              label: const Text('Hapus'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.withValues(
                                  alpha: 0.05,
                                ),
                                foregroundColor: Colors.red,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Makanan?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${food.name} dari daftar?',
        ), //text
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ), //text button
          TextButton(
            onPressed: () {
              ref.read(foodProvider.notifier).deleteFood(food.id);
              ref
                  .read(historyProvider.notifier)
                  .addEntry(
                    'Menghapus',
                    food.name,
                    LucideIcons.trash2,
                    Colors.red,
                  );
              Navigator.pop(context); // Dialog
              Navigator.pop(context); // Detail Screen
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// --- CATEGORIES SCREEN ---

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foods = ref.watch(foodProvider);
    final categories = [
      {'name': 'Semua', 'icon': LucideIcons.layoutGrid, 'color': Colors.blue},
      {'name': 'Minuman', 'icon': LucideIcons.cupSoda, 'color': Colors.cyan},
      {
        'name': 'Makanan Instan',
        'icon': LucideIcons.box,
        'color': Colors.orange,
      },
      {'name': 'Buah', 'icon': LucideIcons.apple, 'color': Colors.red},
      {'name': 'Sayuran', 'icon': LucideIcons.carrot, 'color': Colors.green},
      {
        'name': 'Daging',
        'icon': LucideIcons.drumstick,
        'color': Colors.redAccent,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAF8),
        surfaceTintColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ), //BoxDecoration
            ), //Container
          ), //Positioned
          Positioned(
            bottom: 50,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ), //BoxDecoration
            ), //Container
          ), //positioned
          ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final name = cat['name'] as String;
              final count = name == 'Semua'
                  ? foods.length
                  : foods.where((f) => f.category == name).length;

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FilteredFoodScreen(
                        categoryName: name,
                        foods: name == 'Semua'
                            ? foods
                            : foods.where((f) => f.category == name).toList(),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ), //BoxShadow
                    ],
                  ), //BoxDecoration
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (cat['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: cat['color'] as Color,
                        ), //Icon
                      ), //Container
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ), //TextStyle
                            ), //Text
                            Text(
                              '$count makanan',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ), //TextStyle
                            ), //Text
                          ],
                        ), //Column
                      ), //Expanded
                      Text(
                        count.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        LucideIcons.chevronRight,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- NEW SCREENS: NOTIFICATION & FILTERED FOOD ---

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foods = ref.watch(foodProvider);
    final notifications =
        foods.where((f) => f.status != FoodStatus.aman).toList()
          ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi'), centerTitle: true),
      body: notifications.isEmpty
          ? const Center(child: Text('Tidak ada notifikasi baru'))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final food = notifications[index];
                final isExpired = food.status == FoodStatus.expired;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (isExpired ? Colors.red : Colors.orange)
                          .withValues(alpha: 0.1),
                    ), //Border.All
                  ), //BoxDecoration
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isExpired ? Colors.red : Colors.orange)
                              .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isExpired
                              ? LucideIcons.alertTriangle
                              : LucideIcons.clock,
                          color: isExpired ? Colors.red : Colors.orange,
                          size: 20,
                        ), //Icon
                      ), //Container
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isExpired
                                  ? 'Awas! ${food.name} sudah kadaluarsa'
                                  : '${food.name} akan kadaluarsa segera',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ), //TextStyle
                            ), //Text
                            Text(
                              isExpired
                                  ? 'Sudah lewat ${-food.daysLeft} hari'
                                  : 'Tersisa ${food.daysLeft} hari lagi',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideX(begin: 0.1, end: 0);
              },
            ),
    );
  }
}

class FilteredFoodScreen extends StatelessWidget {
  final String categoryName;
  final List<FoodItem> foods;

  const FilteredFoodScreen({
    super.key,
    required this.categoryName,
    required this.foods,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAF8),
        surfaceTintColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: false,
      body: foods.isEmpty
          ? const Center(child: Text('Tidak ada makanan di kategori ini'))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: foods.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final food = foods[index];
                return _FoodItemTile(food: food);
              },
            ),
    );
  }
}

class _FoodItemTile extends StatelessWidget {
  final FoodItem food;
  const _FoodItemTile({required this.food});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    switch (food.status) {
      case FoodStatus.aman:
        statusColor = const Color(0xFF4CAF50);
        statusLabel = 'Aman';
        break;
      case FoodStatus.hampir:
        statusColor = const Color(0xFFFF9800);
        statusLabel = 'Hampir';
        break;
      case FoodStatus.expired:
        statusColor = const Color(0xFFF44336);
        statusLabel = 'Expired';
        break;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FoodDetailScreen(food: food)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ), //BoxShadow
          ],
        ), //BoxDecoration
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: food.imagePath != null && food.imagePath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(food.imagePath!),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(_getCategoryIcon(food.category), color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ), //TextStyle
                  ), //Text
                  Text(
                    'Kadaluarsa: ${DateFormat('d MMM yyyy', 'id_ID').format(food.expiryDate)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ), //Text
                ],
              ), //Column
            ), //Expanded
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Minuman':
        return LucideIcons.cupSoda;
      case 'Makanan Instan':
        return LucideIcons.box;
      case 'Buah':
        return LucideIcons.apple;
      case 'Sayuran':
        return LucideIcons.carrot;
      case 'Daging':
        return LucideIcons.drumstick;
      default:
        return LucideIcons.utensils;
    }
  }
}

// --- HISTORY SCREEN ---

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAF8),
        surfaceTintColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          Positioned(
            top: 100,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ), //Box Decoration
            ), // Container
          ), // Positioned
          history.isEmpty
              ? const Center(child: Text('Belum ada riwayat'))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: entry.color.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ), //Box Decoration
                                child: Icon(
                                  entry.icon,
                                  color: entry.color,
                                  size: 20,
                                ), //Icon
                              ), //Container
                              if (index != history.length - 1)
                                Container(
                                  width: 2,
                                  height: 40,
                                  color: Colors.grey.withValues(alpha: 0.1),
                                ), //Container
                            ],
                          ), //Column
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry.title} ${entry.foodName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'd MMM yyyy • HH:mm',
                                    'id_ID',
                                  ).format(entry.timestamp),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

// ABOUT SCREEN

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final foods = ref.watch(foodProvider);
    final notificationCount = foods
        .where((f) => f.status != FoodStatus.aman)
        .length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAF8),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ), //App Bar
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          // Background Decorations
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ), //BoxDecoration
            ), //Container
          ), //Positioned
          Positioned(
            bottom: 200,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF8BC34A).withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              children: [
                // Profile Header
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF4CAF50),
                        backgroundImage: profile.imagePath != null
                            ? FileImage(File(profile.imagePath!))
                            : null,
                        child: profile.imagePath == null
                            ? Text(
                                profile.name.isNotEmpty
                                    ? profile.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ), //TextStyle
                              ) //text
                            : null,
                      ), //CircleAvatar
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Icon(
                              LucideIcons.camera,
                              size: 14,
                              color: Color(0xFF4CAF50),
                            ), //Icon
                          ), //CircleAvatar
                        ), //GestureDetector
                      ), //Positioned
                    ],
                  ), //Stack
                ), //Center
                const SizedBox(height: 16),
                Text(
                  profile.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  profile.email,
                  style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Settings Section
                _buildSectionHeader('Akun'),
                _buildAboutTile(
                  icon: LucideIcons.user,
                  title: 'Edit Profil',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ), //MaterialPageRoute
                  ),
                ),
                _buildAboutTile(
                  icon: LucideIcons.bell,
                  title: 'Notifikasi',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  ),
                  trailing: notificationCount > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            notificationCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Informasi'),
                _buildAboutTile(
                  icon: LucideIcons.leaf,
                  title: 'Tentang FreshTrack',
                  onTap: () => _showInfoDialog(
                    context,
                    'Tentang FreshTrack',
                    'FreshTrack adalah asisten pintar untuk melacak masa kadaluarsa makanan Anda. Kami membantu mengurangi pemborosan makanan dengan memberikan pengingat tepat waktu.',
                  ),
                ),
                _buildAboutTile(
                  icon: LucideIcons.shieldCheck,
                  title: 'Kebijakan Privasi',
                  onTap: () => _showInfoDialog(
                    context,
                    'Kebijakan Privasi',
                    'Data Anda disimpan secara lokal di perangkat Anda. Kami tidak mengumpulkan atau membagikan data pribadi Anda ke pihak ketiga.',
                  ),
                ),
                _buildAboutTile(
                  icon: LucideIcons.mail,
                  title: 'Hubungi Kami',
                  onTap: () => _showInfoDialog(
                    context,
                    'Hubungi Kami',
                    'Punya saran atau pertanyaan? Hubungi kami di support@freshtrack.com atau kunjungi website kami.',
                  ),
                ),
                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => _showLogoutConfirm(context),
                    icon: const Icon(LucideIcons.logOut, color: Colors.red),
                    label: const Text(
                      'Keluar Sesi',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ), //TextStyle
                    ), //Text
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ), //RoundedRectangleBorder
                    ),
                  ), //TextButtonIcon
                ), //SizedBox
                const SizedBox(height: 40),
                Text(
                  '© 2026 FreshTrack Team • v1.0.0',
                  style: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Sesi?'),
        content: const Text('Apakah Anda yakin ingin keluar dari sesi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ), //BoxShadow
          ],
        ), //BoxDecoration
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: Colors.grey[700]),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ), //Text
            const Spacer(),
            if (trailing != null) ...[trailing, const SizedBox(width: 8)],
            const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// --- EDIT PROFILE SCREEN ---

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _imagePath = profile.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
      );
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking profile image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ), //BoxDecoration
            ), //Container
          ), //Positioned
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: _imagePath != null
                              ? FileImage(File(_imagePath!))
                              : null,
                          child: _imagePath == null
                              ? const Icon(
                                  LucideIcons.user,
                                  size: 60,
                                  color: Colors.grey,
                                ) //Icon
                              : null,
                        ), //CircleAvatar
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ), //BoxDecoration
                            child: const Icon(
                              LucideIcons.camera,
                              size: 18,
                              color: Colors.white,
                            ), //Icon
                          ), //Container
                        ), //Positioned
                      ],
                    ), //Stack
                  ), //Gesture Detector
                ), //Center
                const SizedBox(height: 40),
                _buildLabel('Nama Lengkap'),
                TextField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('Masukkan nama Anda'),
                ), //TextField
                const SizedBox(height: 20),
                _buildLabel('Email'),
                TextField(
                  controller: _emailController,
                  decoration: _buildInputDecoration('Masukkan email Anda'),
                  keyboardType: TextInputType.emailAddress,
                ), //TextField
                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isEmpty) return;
                      ref
                          .read(userProfileProvider.notifier)
                          .updateProfile(
                            name: _nameController.text,
                            email: _emailController.text,
                            imagePath: _imagePath,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil berhasil diperbarui'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ), //RoundedRectangleBorder
                    ),
                    child: const Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

Widget buildPlatformImage(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  if (kIsWeb) {
    return Image.network(path, width: width, height: height, fit: fit);
  }
  return Image.file(File(path), width: width, height: height, fit: fit);
}

ImageProvider buildPlatformImageProvider(String path) {
  if (kIsWeb) {
    return NetworkImage(path);
  }
  return FileImage(File(path));
}
