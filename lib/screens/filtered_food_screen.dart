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
