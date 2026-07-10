import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../providers/expense_cubit.dart';
import '../../data/category_model.dart';

class AddExpenseModal extends StatefulWidget {
  final DateTime initialDate;
  final Function(
    String name,
    double amount,
    String type,
    String category,
    String? notes,
    DateTime entryDate,
  )
  onSave;

  const AddExpenseModal({
    super.key,
    required this.initialDate,
    required this.onSave,
  });

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _selectedDate;
  String _selectedType = 'expense';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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

  void _openManageCategoriesDialog(
    BuildContext context,
    List<CategoryModel> categories,
  ) {
    final newCategoryCtrl = TextEditingController();
    // 🚀 THE FIX: Dialog ke liye bhi Cubit pakdo
    final cubit = context.read<ExpenseCubit>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        // 🚀 THE FIX: Dialog route ko BlocProvider do
        return BlocProvider.value(
          value: cubit,
          child: AlertDialog(
            title: const Text(
              'Manage Categories',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newCategoryCtrl,
                          decoration: const InputDecoration(
                            hintText: 'New Category Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.black,
                          size: 36,
                        ),
                        onPressed: () {
                          if (newCategoryCtrl.text.trim().isNotEmpty) {
                            cubit.addCustomCategory(
                              newCategoryCtrl.text.trim(),
                            );
                            newCategoryCtrl.clear();
                            Navigator.pop(dialogCtx);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  categories.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No custom categories found.'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: categories.length,
                          itemBuilder: (ctx, i) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                categories[i].name,
                                style: const TextStyle(fontSize: 16),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  cubit.removeCustomCategory(categories[i].id);
                                  Navigator.pop(dialogCtx);
                                },
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🚀 THE FIX: Poore form ko BlocBuilder me daal diya aur Loading state ignore kardi
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      buildWhen: (previous, current) => current is ExpenseLoaded,
      builder: (context, state) {
        List<CategoryModel> liveCategories = [];
        if (state is ExpenseLoaded) liveCategories = state.categories;

        // 🚀 THE FIX: Safe Category Selection without crashing
        if (liveCategories.isNotEmpty) {
          final exists = liveCategories.any((c) => c.name == _selectedCategory);
          if (!exists) _selectedCategory = liveCategories.first.name;
        } else {
          _selectedCategory = null;
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'New Entry',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.black,
                        ),
                        label: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name / Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Please enter a name'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (₹)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val == null || double.tryParse(val) == null
                        ? 'Invalid amount'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'expense',
                        child: Text('Expense (Kharcha)'),
                      ),
                      DropdownMenuItem(
                        value: 'income',
                        child: Text('Income (Kamai)'),
                      ),
                    ],
                    onChanged: (val) => setState(() => _selectedType = val!),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: liveCategories
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat.name,
                                  child: Text(cat.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedCategory = val);
                          },
                          validator: (val) => val == null
                              ? 'Please create a category first'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => _openManageCategoriesDialog(
                          context,
                          liveCategories,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate() &&
                            _selectedCategory != null) {
                          widget.onSave(
                            _nameController.text,
                            double.parse(_amountController.text),
                            _selectedType,
                            _selectedCategory!,
                            _notesController.text.isEmpty
                                ? null
                                : _notesController.text,
                            _selectedDate,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Save Entry',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
