import 'package:flutter/material.dart';

class EarningCard extends StatelessWidget {
  final String title;
  final double amount;
  final String comparison;
  final double changeAmount;

  const EarningCard({
    super.key, // key 매개변수 추가
    required this.title,
    required this.amount,
    required this.comparison,
    required this.changeAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'US\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                changeAmount >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                color: changeAmount >= 0 ? Colors.green : Colors.red,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '+US\$${changeAmount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: changeAmount >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                ' vs $comparison',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
