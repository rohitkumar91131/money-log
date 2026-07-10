import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/expense_model.dart';
import '../../providers/expense_cubit.dart';
import '../widgets/premium_expense_card.dart';
import '../widgets/add_expense_modal.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  DateTime? _selectedDate;

  String _getDateLabel() {
    if (_selectedDate == null) return 'All Transactions';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selected = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );

    if (selected == today) return 'Today';
    if (selected == yesterday) return 'Yesterday';
    return '${selected.day}/${selected.month}/${selected.year}';
  }

  void _openAddExpenseModal(BuildContext context) {
    // 🚀 THE FIX: Purane context se Cubit ko pakdo
    final cubit = context.read<ExpenseCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        // 🚀 THE FIX: Nayi screen ko BlocProvider.value ke through pass kar do
        return BlocProvider.value(
          value: cubit,
          child: AddExpenseModal(
            initialDate: _selectedDate ?? DateTime.now(),
            onSave: (name, amount, type, category, notes, entryDate) {
              final newExpense = ExpenseModel(
                name: name,
                amount: amount,
                expenseType: type,
                category: category,
                notes: notes,
                entryDate: entryDate,
              );
              cubit.addNewExpense(newExpense);
            },
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.black),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: GestureDetector(
          onTap: _pickDate,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getDateLabel(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black,
                size: 28,
              ),
            ],
          ),
        ),
        actions: [
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: () => setState(() => _selectedDate = null),
            ),
        ],
      ),
      body: BlocBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading)
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          if (state is ExpenseError)
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );

          if (state is ExpenseLoaded) {
            List<ExpenseModel> displayList = state.expenses;
            if (_selectedDate != null) {
              displayList = state.expenses
                  .where(
                    (item) =>
                        item.entryDate.year == _selectedDate!.year &&
                        item.entryDate.month == _selectedDate!.month &&
                        item.entryDate.day == _selectedDate!.day,
                  )
                  .toList();
            }

            if (displayList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions for ${_getDateLabel().toLowerCase()}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: displayList.length,
              itemBuilder: (context, index) =>
                  PremiumExpenseCard(expense: displayList[index]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _openAddExpenseModal(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
