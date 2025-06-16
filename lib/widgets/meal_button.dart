import 'package:flutter/material.dart';

class MealButton extends StatefulWidget {
  final String meal;
  final Function(String, bool) onResponse;

  const MealButton({
    super.key,
    required this.meal,
    required this.onResponse,
  });

  @override
  _MealButtonState createState() => _MealButtonState();
}

class _MealButtonState extends State<MealButton> {
  bool showOptions = false;

  String getMealTitle() {
    final time = widget.meal[0].toUpperCase() + widget.meal.substring(1);
    return 'Had $time?';
  }

  @override
  Widget build(BuildContext context) {
    if (!showOptions) {
      return GestureDetector(
        onTap: () => setState(() => showOptions = true),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3b82f6), Color(0xFF2563eb)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          width: double.infinity,
          child: Center(
            child: Text(
              getMealTitle(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Text(
          'Record your ${widget.meal}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                widget.onResponse(widget.meal, true);
                setState(() => showOptions = false);
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF10b981),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 32),
            GestureDetector(
              onTap: () {
                widget.onResponse(widget.meal, false);
                setState(() => showOptions = false);
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFef4444),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}