import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/food_item.dart';
import '../utils/platform_utils.dart';
import 'food_detail_screen.dart';

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