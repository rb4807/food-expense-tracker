import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/daily_expense.dart';
import '../models/meal_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _storageKey = 'foodExpenses';
  
  static final Map<String, int> _mealPrices = {
    'breakfast': 30,
    'lunch': 60,
    'dinner': 60,
  };

  static Future<List<DailyExpense>> _loadExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedExpenses = prefs.getString(_storageKey);
      if (savedExpenses == null) return [];
      
      final List<dynamic> jsonList = jsonDecode(savedExpenses);
      return jsonList.map((json) => DailyExpense(
        breakfast: MealData(
          had: json['breakfast']['had'],
          amount: json['breakfast']['amount'],
        ),
        lunch: MealData(
          had: json['lunch']['had'],
          amount: json['lunch']['amount'],
        ),
        dinner: MealData(
          had: json['dinner']['had'],
          amount: json['dinner']['amount'],
        ),
        date: json['date'],
      )).toList();
    } catch (e) {
      print('Error loading expenses: $e');
      return [];
    }
  }

  static Future<void> _saveExpenses(List<DailyExpense> expenses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = expenses.map((expense) => {
        'breakfast': {
          'had': expense.breakfast.had,
          'amount': expense.breakfast.amount,
        },
        'lunch': {
          'had': expense.lunch.had,
          'amount': expense.lunch.amount,
        },
        'dinner': {
          'had': expense.dinner.had,
          'amount': expense.dinner.amount,
        },
        'date': expense.date,
      }).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving expenses: $e');
    }
  }

  static Future<DailyExpense> getTodayExpense([DateTime? date]) async {
    final dateStr = date != null 
        ? DateFormat('yyyy-MM-dd').format(date) 
        : DateFormat('yyyy-MM-dd').format(DateTime.now());
    final expenses = await _loadExpenses();
    
    return expenses.firstWhere(
      (exp) => exp.date == dateStr,
      orElse: () => DailyExpense(
        breakfast: MealData(had: false, amount: 0),
        lunch: MealData(had: false, amount: 0),
        dinner: MealData(had: false, amount: 0),
        date: dateStr,
      ),
    );
  }

  static Future<DailyExpense> updateTodayExpense(
    String meal, 
    bool hadMeal, 
    [DateTime? date]
  ) async {
    final dateStr = date != null 
      ? DateFormat('yyyy-MM-dd').format(date) 
      : DateFormat('yyyy-MM-dd').format(DateTime.now());
    final expenses = await _loadExpenses();
    
    DailyExpense todayExpense = await getTodayExpense(date);
    
    // Create updated meal data
    MealData updatedBreakfast = todayExpense.breakfast;
    MealData updatedLunch = todayExpense.lunch;
    MealData updatedDinner = todayExpense.dinner;
    
    switch (meal) {
      case 'breakfast':
        updatedBreakfast = MealData(had: hadMeal, amount: hadMeal ? _mealPrices['breakfast']! : 0);
        break;
      case 'lunch':
        updatedLunch = MealData(had: hadMeal, amount: hadMeal ? _mealPrices['lunch']! : 0);
        break;
      case 'dinner':
        updatedDinner = MealData(had: hadMeal, amount: hadMeal ? _mealPrices['dinner']! : 0);
        break;
    }
    
    todayExpense = DailyExpense(
      breakfast: updatedBreakfast,
      lunch: updatedLunch,
      dinner: updatedDinner,
      date: dateStr,
    );
    
    final updatedExpenses = [
      ...expenses.where((exp) => exp.date != dateStr),
      todayExpense,
    ];
    
    await _saveExpenses(updatedExpenses);
    return todayExpense;
  }

  static Future<List<DailyExpense>> getWeeklyExpenses([DateTime? weekStart]) async {
    final start = weekStart ?? _getStartOfWeek(DateTime.now());
    final dates = List.generate(7, (i) => start.add(Duration(days: i)));
    
    final expenses = await _loadExpenses();
    return dates.map((date) {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      return expenses.firstWhere(
        (exp) => exp.date == dateStr,
        orElse: () => DailyExpense(
          breakfast: MealData(had: false, amount: 0),
          lunch: MealData(had: false, amount: 0),
          dinner: MealData(had: false, amount: 0),
          date: dateStr,
        ),
      );
    }).toList();
  }

  static DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static Future<List<DailyExpense>> getMonthlyExpenses([DateTime? month]) async {
    final targetMonth = month ?? DateTime.now();
    final firstDay = DateTime(targetMonth.year, targetMonth.month, 1);
    final lastDay = DateTime(targetMonth.year, targetMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    
    final expenses = await _loadExpenses();
    return List.generate(daysInMonth, (i) {
      final date = DateTime(targetMonth.year, targetMonth.month, i + 1);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      return expenses.firstWhere(
        (exp) => exp.date == dateStr,
        orElse: () => DailyExpense(
          breakfast: MealData(had: false, amount: 0),
          lunch: MealData(had: false, amount: 0),
          dinner: MealData(had: false, amount: 0),
          date: dateStr,
        ),
      );
    });
  }

  static String? checkCurrentMeal() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentDay = now.weekday; // 1 (Monday) to 7 (Sunday)

    // Only show buttons on weekdays (Monday to Friday)
    if (currentDay == 6 || currentDay == 7) return null;

    if (currentHour >= 9 && currentHour <= 11) return 'breakfast';
    if (currentHour >= 13 && currentHour <= 15) return 'lunch';
    if (currentHour >= 19 && currentHour <= 22) return 'dinner';
    
    return null;
  }
}