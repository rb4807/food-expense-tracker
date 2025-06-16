import 'package:flutter/material.dart';
import '../models/daily_expense.dart';

class MealEditModal extends StatefulWidget {
  final bool visible;
  final VoidCallback onClose;
  final Function(String, bool) onSave;
  final DailyExpense mealData;
  final String selectedMeal;

  const MealEditModal({
    super.key,
    required this.visible,
    required this.onClose,
    required this.onSave,
    required this.mealData,
    required this.selectedMeal,
  });

  @override
  State<MealEditModal> createState() => _MealEditModalState();
}

class _MealEditModalState extends State<MealEditModal> {
  String currentSelectedMeal = 'breakfast';

  @override
  void initState() {
    super.initState();
    currentSelectedMeal = widget.selectedMeal;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF0f3457),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Meal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Meal options
              _buildMealOption('breakfast', '9-11 AM', 30),
              _buildMealOption('lunch', '1-3 PM', 60),
              _buildMealOption('dinner', '7-10 PM', 60),
              
              const SizedBox(height: 20),
              
              // Current status
              Row(
                children: [
                  const Text(
                    'Current Status:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCurrentMealData().had 
                          ? const Color(0xFF10b981) 
                          : const Color(0xFFf59e0b),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getCurrentMealData().had ? 'Had' : 'Not had',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: widget.onClose,
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3b82f6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final currentMealData = _getCurrentMealData();
                        widget.onSave(currentSelectedMeal, !currentMealData.had);
                      },
                      child: Text(
                        _getCurrentMealData().had ? 'Mark as Not Had' : 'Mark as Had',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealOption(String meal, String time, int price) {
    final isSelected = currentSelectedMeal == meal;
    final mealData = _getMealData(meal);

    return GestureDetector(
      onTap: () {
        setState(() {
          currentSelectedMeal = meal;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3b82f6).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF3b82f6), width: 2)
              : Border.all(color: Colors.transparent, width: 2),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getMealIcon(meal),
                color: _getMealColor(meal),
                size: 24,
              ),
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
                  Text(
                    time,
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
                Text(
                  '$price₹',
                  style: const TextStyle(
                    color: Color(0xFF64748b),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: mealData.had ? const Color(0xFF10b981) : const Color(0xFFf59e0b),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    mealData.had ? Icons.check : Icons.access_time,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF3b82f6),
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  dynamic _getMealData(String meal) {
    switch (meal) {
      case 'breakfast':
        return widget.mealData.breakfast;
      case 'lunch':
        return widget.mealData.lunch;
      case 'dinner':
        return widget.mealData.dinner;
      default:
        return widget.mealData.breakfast;
    }
  }

  dynamic _getCurrentMealData() {
    return _getMealData(currentSelectedMeal);
  }

  IconData _getMealIcon(String meal) {
    switch (meal) {
      case 'breakfast':
        return Icons.coffee;
      case 'lunch':
        return Icons.restaurant;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.fastfood;
    }
  }

  Color _getMealColor(String meal) {
    switch (meal) {
      case 'breakfast':
        return const Color(0xFFf59e0b);
      case 'lunch':
        return const Color(0xFF10b981);
      case 'dinner':
        return const Color(0xFF8b5cf6);
      default:
        return Colors.white;
    }
  }
}