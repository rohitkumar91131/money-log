class ExpenseModel {
  final String? id;
  final String name;
  final double amount;
  final String expenseType;
  final String category;
  final String? notes;
  final DateTime entryDate; // User selected date
  final DateTime? createdAt; // DB creation time

  ExpenseModel({
    this.id,
    required this.name,
    required this.amount,
    required this.expenseType,
    required this.category,
    this.notes,
    required this.entryDate,
    this.createdAt,
  });

  // Flutter to Supabase (JSON)
  Map<String, dynamic> toJson(String userId) {
    return {
      'user_id': userId,
      'name': name,
      'amount': amount,
      'expense_type': expenseType,
      'category': category,
      'notes': notes,
      'entry_date': entryDate.toIso8601String().split('T')[0],
    };
  }

  // Supabase to Flutter (Object)
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      expenseType: json['expense_type'],
      category: json['category'],
      notes: json['notes'],
      entryDate: DateTime.parse(json['entry_date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
