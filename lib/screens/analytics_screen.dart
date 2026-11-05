import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../providers/expense_provider.dart';
import '../models/expense.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final Color navy = const Color(0xFF172554);
  final Color blue = const Color(0xFF315CDB);
  final Color green = const Color(0xFF16A36A);
  final Color red = const Color(0xFFEF5350);

  String money(double value) =>
      NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(value);

  List<Expense> getMonthExpenses(List<Expense> expenses) {
    return expenses
        .where(
          (e) => e.date.month == selectedMonth && e.date.year == selectedYear,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final allExpenses = provider.expenses;
    final monthly = getMonthExpenses(allExpenses);

    final income = monthly
        .where((e) => e.isIncome)
        .fold(0.0, (sum, e) => sum + e.amount);

    final expenses = monthly
        .where((e) => !e.isIncome)
        .fold(0.0, (sum, e) => sum + e.amount);

    final balance = income - expenses;

    final categories = <String, double>{};
    for (final e in monthly.where((e) => !e.isIncome)) {
      categories[e.category] = (categories[e.category] ?? 0) + e.amount;
    }

    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: TextStyle(
            color: navy,
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
        backgroundColor: const Color(0xFFF6F7FB),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _monthSelector(),
                const SizedBox(height: 20),

                _summaryCard(income, expenses, balance),

                const SizedBox(height: 25),

                _sectionTitle('Income vs Expenses'),
                const SizedBox(height: 12),
                _incomeExpenseChart(income, expenses),

                const SizedBox(height: 25),

                _sectionTitle('Spending by Category'),
                const SizedBox(height: 12),
                _categoryChart(sortedCategories, expenses),

                const SizedBox(height: 25),

                _sectionTitle('Category Breakdown'),
                const SizedBox(height: 12),
                _categoryList(sortedCategories, expenses),

                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _monthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                selectedMonth--;
                if (selectedMonth < 1) {
                  selectedMonth = 12;
                  selectedYear--;
                }
              });
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            DateFormat('MMMM yyyy')
                .format(DateTime(selectedYear, selectedMonth)),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                final now = DateTime.now();
                if (selectedYear < now.year ||
                    (selectedYear == now.year && selectedMonth < now.month)) {
                  selectedMonth++;
                  if (selectedMonth > 12) {
                    selectedMonth = 1;
                    selectedYear++;
                  }
                }
              });
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(double income, double expenses, double balance) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF172554), Color(0xFF315CDB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: blue.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MONTHLY NET BALANCE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            money(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _summaryItem('Income', income, green)),
              Expanded(child: _summaryItem('Expenses', expenses, red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 8, color: color),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          money(amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _incomeExpenseChart(double income, double expenses) {
    final maximum = [income, expenses, 100.0].reduce((a, b) => a > b ? a : b);

    return Container(
      height: 230,
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          maxY: maximum * 1.25,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 42),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final label = value.toInt() == 0 ? 'Income' : 'Expense';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(label, style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
          ),
          barGroups: [_bar(0, income, green), _bar(1, expenses, red)],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double amount, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: amount,
          color: color,
          width: 34,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _categoryChart(
    List<MapEntry<String, double>> categories,
    double total,
  ) {
    if (categories.isEmpty) {
      return _emptyCard('No expense data for this month.');
    }

    final colors = [
      blue,
      green,
      red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];

    return Container(
      height: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 48,
          sectionsSpace: 4,
          sections: List.generate(categories.length, (i) {
            final item = categories[i];
            final percentage = total == 0 ? 0.0 : item.value / total * 100;

            return PieChartSectionData(
              color: colors[i % colors.length],
              value: item.value,
              title: '${percentage.toStringAsFixed(0)}%',
              radius: 75,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _categoryList(
    List<MapEntry<String, double>> categories,
    double total,
  ) {
    if (categories.isEmpty) {
      return _emptyCard('Your category report will appear here.');
    }

    final colors = [
      blue,
      green,
      red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: List.generate(categories.length, (i) {
          final item = categories[i];
          final percent = total == 0 ? 0.0 : item.value / total;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.key,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      money(item.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFEDF0F7),
                    valueColor: AlwaysStoppedAnimation(
                      colors[i % colors.length],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.insert_chart_outlined, size: 38, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
