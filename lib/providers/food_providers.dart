import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_item.dart';
import '../service/notification_service.dart';

class FoodNotifier extends Notifier<List<FoodItem>> {
  @override
  List<FoodItem> build() {
    return [];
  }

  void addFood(FoodItem food) {
    state = [...state, food];
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
    NotificationService().cancelNotifications(updatedFood.id.toString());
    NotificationService().scheduleFoodExpiryNotification(
      id: updatedFood.id.toString(),
      name: updatedFood.name,
      expiryDate: updatedFood.expiryDate,
    );
  }

  void deleteFood(int id) {
    state = state.where((f) => f.id != id).toList();
    NotificationService().cancelNotifications(id.toString());
  }

  void clearAll() {
    for (final food in state) {
      NotificationService().cancelNotifications(food.id.toString());
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
