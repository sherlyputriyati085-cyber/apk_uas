import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/food_provider.dart';
import 'filtered_food_screen.dart';

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
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),