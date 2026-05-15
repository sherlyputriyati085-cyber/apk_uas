import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/food_item.dart';
import '../providers/food_provider.dart';
import '../providers/history_provider.dart';
import '../utils/platform_utils.dart';
import 'add_food_screen.dart';

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
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  child: food.imagePath != null
                      ? buildPlatformImage(
                          food.imagePath!,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Icon(
                            LucideIcons.image,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                        ),
                ),