import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_expense.dart';
import '../services/storage_service.dart';

class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  _MonthlyScreenState createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  List<DailyExpense> monthlyExpenses = [];
  List<Map<String, dynamic>> weeklyBreakdown = [];
  DateTime currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    
    final allExpenses = await StorageService.getMonthlyExpenses();
    final filteredExpenses = allExpenses.where((expense) {
      final date = DateFormat('yyyy-MM-dd').parse(expense.date);
      return date.isAfter(firstDay.subtract(const Duration(days: 1))) && 
             date.isBefore(lastDay.add(const Duration(days: 1)));
    }).toList();
    
    setState(() => monthlyExpenses = filteredExpenses);
    
    // Calculate weekly breakdown
    final weeks = <Map<String, dynamic>>[];
    DateTime currentWeekStart = firstDay;
    
    while (currentWeekStart.isBefore(lastDay)) {
      DateTime currentWeekEnd = currentWeekStart.add(const Duration(days: 6));
      if (currentWeekEnd.isAfter(lastDay)) {
        currentWeekEnd = lastDay;
      }
      
      final weekExpenses = filteredExpenses.where((expense) {
        final date = DateFormat('yyyy-MM-dd').parse(expense.date);
        return date.isAfter(currentWeekStart.subtract(const Duration(days: 1))) && 
               date.isBefore(currentWeekEnd.add(const Duration(days: 1)));
      }).toList();
      
      final total = weekExpenses.fold(0, (sum, day) => sum + day.total);
      
      weeks.add({
        'weekStart': currentWeekStart,
        'weekEnd': currentWeekEnd,
        'total': total,
      });
      
      currentWeekStart = currentWeekEnd.add(const Duration(days: 1));
    }
    
    setState(() => weeklyBreakdown = weeks);
  }

  void _goToPreviousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
      loadData();
    });
  }

  void _goToNextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalMonth = monthlyExpenses.fold(0, (sum, day) => sum + day.total);
    final monthName = DateFormat('MMMM yyyy').format(currentMonth);

    return Container(
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
                // Month navigation header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: _goToPreviousMonth,
                    ),
                    Column(
                      children: [
                        const Text(
                          'Monthly Summary',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          monthName,
                          style: const TextStyle(
                            color: Color(0xFF94a3b8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onPressed: _goToNextMonth,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Monthly Total Card
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
                              "Current Month Total",
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
                              child: Text(
                                DateFormat('MMMM').format(currentMonth),
                                style: const TextStyle(
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
                          '${totalMonth}₹',
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
                
                const Text(
                  'Weekly Breakdown',
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
                    children: weeklyBreakdown.map((week) {
                      return Container(
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
                              child: const Center(
                                child: Icon(
                                  Icons.calendar_view_week,
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
                                    'Week ${weeklyBreakdown.indexOf(week) + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${DateFormat('MMM d').format(week['weekStart'] as DateTime)} - ${DateFormat('MMM d').format(week['weekEnd'] as DateTime)}',
                                    style: const TextStyle(
                                      color: Color(0xFF94a3b8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${week['total']}₹',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
    );
  }
}