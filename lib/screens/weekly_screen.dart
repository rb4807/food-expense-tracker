import 'package:flutter/material.dart';
import 'package:food_tracker/models/meal_data.dart';
import 'package:intl/intl.dart';
import '../models/daily_expense.dart';
import '../services/storage_service.dart';
import '../widgets/meal_edit_modal.dart';

class WeeklyScreen extends StatefulWidget {
  const WeeklyScreen({super.key});

  @override
  State<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  List<DailyExpense> weeklyExpenses = [];
  bool modalVisible = false;
  DailyExpense? selectedDay;
  String selectedMeal = 'breakfast';
  DateTime currentWeekStart = DateTime.now();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentWeekStart = _getStartOfWeek(DateTime.now());
    loadData();
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Future<void> loadData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final expenses = await StorageService.getWeeklyExpenses(currentWeekStart);
      
      // Filter to show only weekdays (Monday to Friday)
      final weekdayExpenses = expenses.where((day) {
        final date = DateFormat('yyyy-MM-dd').parse(day.date);
        return date.weekday >= 1 && date.weekday <= 5;
      }).toList();

      if (mounted) {
        setState(() {
          weeklyExpenses = weekdayExpenses;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading weekly data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMealEditModal(DailyExpense day) {
    setState(() {
      selectedDay = day;
      modalVisible = true;
    });
  }

  Future<void> _handleMealUpdate(String meal, bool hadMeal) async {
    if (selectedDay != null) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(selectedDay!.date);
        await StorageService.updateTodayExpense(meal, hadMeal, date);
        await loadData();
      } catch (e) {
        print('Error updating meal: $e');
      }
    }
    setState(() => modalVisible = false);
  }

  void _goToPreviousWeek() {
    setState(() {
      currentWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    });
    loadData();
  }

  void _goToNextWeek() {
    setState(() {
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    });
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0a2540), Color(0xFF0f3457), Color(0xFF18456f)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7ae7ff)),
                ),
                SizedBox(height: 20),
                Text(
                  'Loading weekly data...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFe2e8f0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final totalWeek = weeklyExpenses.fold(0, (sum, day) => sum + day.total);
    final weekRange = '${DateFormat('MMM d').format(currentWeekStart)} - '
        '${DateFormat('MMM d').format(currentWeekStart.add(const Duration(days: 4)))}'; // Only show till Friday

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0a2540), Color(0xFF0f3457), Color(0xFF18456f)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with week navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: _goToPreviousWeek,
                        ),
                        Column(
                          children: [
                            const Text(
                              'Weekly Summary',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              weekRange,
                              style: const TextStyle(
                                color: Color(0xFF94a3b8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          onPressed: _goToNextWeek,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Weekly total card
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF18456f), Color(0xFF0f3457)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Current Week Total",
                                  style: TextStyle(
                                    color: Color(0xFF94a3b8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'WORKING DAYS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${totalWeek}₹',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Daily breakdown section
                    const Text(
                      'Daily Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: weeklyExpenses.map((day) {
                          final date = DateFormat('yyyy-MM-dd').parse(day.date);
                          final isLastItem = weeklyExpenses.indexOf(day) == weeklyExpenses.length - 1;
                          
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: isLastItem ? null : Border(
                                bottom: BorderSide(
                                  color: Colors.white.withOpacity(0.05),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.calendar_today,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('EEEE').format(date),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('MMM d').format(date),
                                        style: const TextStyle(
                                          color: Color(0xFF94a3b8),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${day.total}₹',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _showMealEditModal(day),
                                  child: const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF94a3b8),
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Meal Edit Modal
        if (modalVisible && selectedDay != null)
          MealEditModal(
            visible: modalVisible,
            onClose: () => setState(() => modalVisible = false),
            onSave: _handleMealUpdate,
            mealData: selectedDay!,
            selectedMeal: selectedMeal,
          ),
      ],
    );
  }
}