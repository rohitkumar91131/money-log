import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/expense_model.dart';
import '../../providers/expense_cubit.dart';

class EntryDetailPage extends StatefulWidget {
  final ExpenseModel expense;

  const EntryDetailPage({super.key, required this.expense});

  @override
  State<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends State<EntryDetailPage> {
  bool _isEditing = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.expense.name);
    _amountCtrl = TextEditingController(text: widget.expense.amount.toString());
    _notesCtrl = TextEditingController(text: widget.expense.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_nameCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Name and Amount cannot be empty!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedExpense = ExpenseModel(
      id: widget.expense.id,
      name: _nameCtrl.text.trim(),
      amount: double.tryParse(_amountCtrl.text.trim()) ?? widget.expense.amount,
      expenseType: widget.expense.expenseType,
      category: widget.expense.category,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      entryDate: widget.expense.entryDate,
      createdAt: widget.expense.createdAt,
    );

    context.read<ExpenseCubit>().updateExistingExpense(updatedExpense);

    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Entry updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteEntry() {
    if (widget.expense.id != null) {
      context.read<ExpenseCubit>().removeExpense(widget.expense.id!);
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('🗑️ Entry deleted!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.expense.expenseType == 'income';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Entry?'),
                  content: const Text(
                    'Are you sure you want to delete this transaction?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _deleteEntry();
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        // 🚀 THE FIX: Swipe Right to Go Back Logic
        onHorizontalDragEnd: (details) {
          // Check if the swipe was to the right with decent speed
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 300) {
            Navigator.pop(context); // Go back to the previous screen
          }
        },
        onTap: () {
          if (!_isEditing) setState(() => _isEditing = true);
        },
        // The rest of your UI stays exactly the same
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.expense.entryDate.day}/${widget.expense.entryDate.month}/${widget.expense.entryDate.year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _isEditing
                  ? TextField(
                      controller: _nameCtrl,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        hintText: 'Title',
                      ),
                    )
                  : Text(
                      _nameCtrl.text,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

              const SizedBox(height: 16),

              _isEditing
                  ? TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        prefixText: '₹ ',
                      ),
                    )
                  : Text(
                      '₹ ${_amountCtrl.text}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),

              const SizedBox(height: 40),

              const Text(
                'NOTES',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              _isEditing
                  ? TextField(
                      controller: _notesCtrl,
                      maxLines: null,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        hintText: 'Add extra details here...',
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _notesCtrl.text.isEmpty
                            ? 'Tap to add notes...'
                            : _notesCtrl.text,
                        style: TextStyle(
                          fontSize: 18,
                          color: _notesCtrl.text.isEmpty
                              ? Colors.grey
                              : Colors.black87,
                          fontStyle: _notesCtrl.text.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton.extended(
              onPressed: _saveChanges,
              backgroundColor: Colors.black,
              elevation: 4,
              label: const Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: const Icon(Icons.check, color: Colors.white),
            )
          : null,
    );
  }
}
