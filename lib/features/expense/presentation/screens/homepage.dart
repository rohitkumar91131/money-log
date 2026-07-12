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
    final cubit = context.read<ExpenseCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: AddExpenseModal(
          initialDate: _selectedDate ?? DateTime.now(),
          onSave: (name, amount, type, category, notes, entryDate) {
            cubit.addNewExpense(
              ExpenseModel(
                name: name,
                amount: amount,
                expenseType: type,
                category: category,
                notes: notes,
                entryDate: entryDate,
              ),
            );
          },
        ),
      ),
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black, size: 28),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, state) {
            String titleText = _getDateLabel();
            Widget? statusIcon;
            Color textColor = Colors.black;
            bool showOfflineDot = false;

            if (state is ExpenseLoaded) {
              showOfflineDot = state.isOffline;

              if (state.syncStatus == SyncStatus.Syncing) {
                titleText = 'Syncing...';
                textColor = Colors.grey[600]!;
                statusIcon = const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey,
                  ),
                );
              } else if (state.syncStatus == SyncStatus.error) {
                titleText = 'Waiting for network...';
                textColor = Colors.orange[700]!;
                statusIcon = Icon(
                  Icons.cloud_off,
                  size: 16,
                  color: Colors.orange[700],
                );
              }
            }

            return GestureDetector(
              onTap: _pickDate,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.0, -0.5),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Row(
                  key: ValueKey<String>(titleText),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titleText,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (statusIcon != null) ...[
                      const SizedBox(width: 8),
                      statusIcon,
                    ] else ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                        size: 24,
                      ),
                      if (showOfflineDot)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.cloud_off,
                            color: Colors.red[300],
                            size: 16,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: () => setState(() => _selectedDate = null),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (state is ExpenseError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
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

            // 🚀 THE MAGIC: RefreshIndicator added!
            return RefreshIndicator(
              color: Colors.black,
              backgroundColor: Colors.white,
              onRefresh: () async {
                // Manually trigger the fetch & sync process
                await context.read<ExpenseCubit>().fetchExpenses();
              },
              child: displayList.isEmpty
                  // If empty, use a scrollable view so pull-to-refresh still works
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions for ${_getDateLabel().toLowerCase()}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  // The populated list
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) =>
                          PremiumExpenseCard(expense: displayList[index]),
                    ),
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
