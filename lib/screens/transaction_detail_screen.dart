import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'add_transaction_screen.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Expense expense;

  const TransactionDetailScreen({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = expense.isIncome;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 25),
            CircleAvatar(
              radius: 42,
              backgroundColor:
                  isIncome ? Colors.green.shade50 : Colors.red.shade50,
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                size: 38,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                expense.title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                '${isIncome ? '+' : '-'}₹${expense.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 35),
            _detailRow('Category', expense.category),
            _detailRow(
              'Date',
              '${expense.date.day}/${expense.date.month}/${expense.date.year}',
            ),
            _detailRow('Type', isIncome ? 'Income' : 'Expense'),
            _detailRow('Transaction ID', expense.id),
            const Spacer(),

            // Edit transaction
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddTransactionScreen(expense: expense),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Transaction'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
              ),
            ),
            const SizedBox(height: 12),

            // Delete transaction
            OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Delete transaction?'),
                    content: const Text(
                      'Are you sure you want to delete this transaction?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed != true || !context.mounted) return;

                try {
                  await context
                      .read<ExpenseProvider>()
                      .deleteExpense(expense.id);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaction deleted successfully'),
                      ),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not delete transaction'),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Transaction'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.all(15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}