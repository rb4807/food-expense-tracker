import 'package:flutter/material.dart';
import 'package:food_tracker/models/daily_expense.dart';
import 'package:food_tracker/models/meal_data.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../widgets/meal_button.dart';
import '../widgets/meal_edit_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DailyExpense? todayExpense;
  String? currentMeal;
  int weeklyTotal = 0;
  int monthlyTotal = 0;
  bool modalVisible = false;
  String selectedMeal = 'breakfast';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final expense = await StorageService.getTodayExpense();
    final weekly = await StorageService.getWeeklyExpenses();
    final monthly = await StorageService.getMonthlyExpenses();
    
    setState(() {
      todayExpense = expense;
      currentMeal = StorageService.checkCurrentMeal();
      weeklyTotal = weekly.fold(0, (sum, day) => sum + day.total);
      monthlyTotal = monthly.fold(0, (sum, day) => sum + day.total);
    });
  }

  Future<void> handleMealResponse(String meal, bool hadMeal) async {
    final updatedExpense = await StorageService.updateTodayExpense(meal, hadMeal);
    setState(() {
      todayExpense = updatedExpense;
    });
    await updateTotals();
  }

  Future<void> updateTotals() async {
    final weekly = await StorageService.getWeeklyExpenses();
    final monthly = await StorageService.getMonthlyExpenses();
    setState(() {
      weeklyTotal = weekly.fold(0, (sum, day) => sum + day.total);
      monthlyTotal = monthly.fold(0, (sum, day) => sum + day.total);
    });
  }

  void openEditModal(String meal) {
    setState(() {
      selectedMeal = meal;
      modalVisible = true;
    });
  }

  Future<void> _handleMealUpdate(String meal, bool hadMeal) async {
    try {
      await StorageService.updateTodayExpense(meal, hadMeal, DateTime.now());
      await loadData();
    } catch (e) {
      print('Error updating meal: $e');
    }
    setState(() => modalVisible = false);
  }

  Icon getMealIcon(String meal) {
    switch (meal) {
      case 'breakfast':
        return const Icon(Icons.coffee, color: Color(0xFFf59e0b), size: 24);
      case 'lunch':
        return const Icon(Icons.restaurant, color: Color(0xFF10b981), size: 24);
      case 'dinner':
        return const Icon(Icons.dinner_dining, color: Color(0xFF8b5cf6), size: 24);
      default:
        return const Icon(Icons.fastfood, color: Colors.white, size: 24);
    }
  }

  String getMealTime(String meal) {
    switch (meal) {
      case 'breakfast':
        return '9-11 AM';
      case 'lunch':
        return '1-3 PM';
      case 'dinner':
        return '7-10 PM';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (todayExpense == null) {
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
                  'Preparing your meal dashboard...',
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

    final totalToday = todayExpense!.total;

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
                    // Header with greeting and wallet info
                    _buildHeader(totalToday),
                    const SizedBox(height: 24),
                    
                    // Daily meals section
                    _buildMealsSection(),
                    const SizedBox(height: 24),
                    
                    // Current meal prompt
                    if (currentMeal != null && !_getMealData(currentMeal!).had)
                      _buildPromptContainer(),
                    
                    // Expense overview
                    _buildExpenseOverview(totalToday),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Meal Edit Modal
        if (modalVisible && todayExpense != null)
          MealEditModal(
            visible: modalVisible,
            onClose: () => setState(() => modalVisible = false),
            onSave: _handleMealUpdate,
            mealData: todayExpense!,
            selectedMeal: selectedMeal,
          ),
      ],
    );
  }

Widget _buildHeader(int totalToday) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 16, color: Color(0xFF94a3b8), fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(text: 'Hey, '),
                      TextSpan(
                        text: 'Rajesh Balasubramaniam',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
      const SizedBox(height: 20),
                Text(
                  DateFormat('EEEE, MMM d').format(DateTime.now()),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748b)),
                ),
              ],
            ),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF3b82f6),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: const Center(
                child: Text(
                  'RB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Wallet card with decorative arc
         Stack(
        children: [
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
                          "Today's Expense",
                          style: TextStyle(
                            color: Color(0xFF94a3b8),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'STAY HEALTHY',
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
                      '${totalToday}₹',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Weekly',
                                style: TextStyle(
                                  color: Color(0xFF94a3b8),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${weeklyTotal}₹',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Monthly',
                                style: TextStyle(
                                  color: Color(0xFF94a3b8),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${monthlyTotal}₹',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Decorative arc in top-right corner
              Positioned(
            top: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(1.2, -1.2),
                    radius: 1.0,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

  Widget _buildMealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Meals",
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
            children: ['breakfast', 'lunch', 'dinner'].map((meal) {
              final mealData = _getMealData(meal);
              return GestureDetector(
                onTap: () => openEditModal(meal),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
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
                        child: Center(child: getMealIcon(meal)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal[0].toUpperCase() + meal.substring(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              getMealTime(meal),
                              style: const TextStyle(
                                color: Color(0xFF94a3b8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: mealData.had ? const Color(0xFF10b981) : const Color(0xFFf59e0b),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              mealData.had ? Icons.check : Icons.access_time,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${mealData.amount}₹',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF94a3b8),
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptContainer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: MealButton(
        meal: currentMeal!,
        onResponse: handleMealResponse,
      ),
    );
  }

  Widget _buildExpenseOverview(int totalToday) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expense Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildOverviewItem('Today', totalToday, Icons.calendar_today, const Color(0xFF3b82f6)),
            _buildOverviewItem('This Week', weeklyTotal, Icons.calendar_view_week, const Color(0xFF10b981)),
            _buildOverviewItem('This Month', monthlyTotal, Icons.calendar_month, const Color(0xFFf59e0b)),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewItem(String label, int value, IconData icon, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 3,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94a3b8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value}₹',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  MealData _getMealData(String meal) {
    switch (meal) {
      case 'breakfast':
        return todayExpense!.breakfast;
      case 'lunch':
        return todayExpense!.lunch;
      case 'dinner':
        return todayExpense!.dinner;
      default:
        return MealData(had: false, amount: 0);
    }
  }
}