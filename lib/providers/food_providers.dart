import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_item.dart';
import '../service/notification_service.dart';
import '../database/database_helper.dart';

class FoodNotifier extends Notifier<List<FoodItem>> {
  @override
  List<FoodItem> build() {
    _loadFoods();
    return [];
  }

  Future<void> _loadFoods() async {
    try {
      final dbFoods = await DatabaseHelper.instance.getFoods();
      final foods = dbFoods.map((e) => FoodItem.fromMap(e)).toList();
      state = foods;
      // Schedule notifications for all loaded foods
      for (final food in foods) {
        NotificationService().scheduleFoodExpiryNotification(
          id: food.id.toString(),
          name: food.name,
          expiryDate: food.expiryDate,
        );
      }
    } catch (e) {
      debugPrint('Error loading foods from DB: $e');
    }
  }

  void addFood(FoodItem food) {
    state = [...state, food];
    // Schedule notification for the newly added food
    NotificationService().scheduleFoodExpiryNotification(
      id: food.id.toString(),
      name: food.name,
      expiryDate: food.expiryDate,
    );
  }

  void updateFood(FoodItem updatedFood) {
    state = [
      for (final food in state)
        if (food.id == updatedFood.id) updatedFood else food,
    ];
    // Cancel previous notifications and schedule new ones for the updated food
    NotificationService().cancelNotifications(updatedFood.id.toString());
    NotificationService().scheduleFoodExpiryNotification(
      id: updatedFood.id.toString(),
      name: updatedFood.name,
      expiryDate: updatedFood.expiryDate,
    );
    // Persist edit to DB
    DatabaseHelper.instance.updateFood(updatedFood.toMap()).catchError((e) {
      debugPrint('Error updating food in DB: $e');
      return 0;
    });
  }

  void deleteFood(int id) {
    state = state.where((f) => f.id != id).toList();
    NotificationService().cancelNotifications(id.toString());
    // Persist delete to DB
    DatabaseHelper.instance.deleteFood(id).catchError((e) {
      debugPrint('Error deleting food from DB: $e');
      return 0;
    });
  }

  void clearAll() {
    for (final food in state) {
      NotificationService().cancelNotifications(food.id.toString());
      DatabaseHelper.instance.deleteFood(food.id).catchError((e) {
        debugPrint('Error clearing food from DB: $e');
        return 0;
      });
    }
    state = [];
  }
}

final foodProvider = NotifierProvider<FoodNotifier, List<FoodItem>>(
  FoodNotifier.new,
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
