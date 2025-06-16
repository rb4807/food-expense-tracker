import 'package:food_tracker/models/meal_data.dart';

class DailyExpense {
  final MealData breakfast;
  final MealData lunch;
  final MealData dinner;
  final String date;

  DailyExpense({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.date,
  });

  int get total => breakfast.amount + lunch.amount + dinner.amount;
}