import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/food_item.dart';
import '../providers/food_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foods = ref.watch(foodProvider);
    final notifications =
        foods.where((f) => f.status != FoodStatus.aman).toList()
          ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAF8),
        surfaceTintColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: false,
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
                    ),
                  ),
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
                        ),
                      ),
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
                              ),
                            ),
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
