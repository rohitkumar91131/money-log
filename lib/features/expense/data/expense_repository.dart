import 'package:supabase_flutter/supabase_flutter.dart';
import 'expense_model.dart';
import 'category_model.dart';

class ExpenseRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================================
  // 💰 EXPENSE APIs
  // ==========================================

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _supabase.from('expenses').insert(expense.toJson(user.id));
    } catch (e) {
      throw Exception('Failed to add entry: $e');
    }
  }

  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final List<dynamic> response = await _supabase
          .from('expenses')
          .select()
          .eq('user_id', user.id)
          .order('entry_date', ascending: false)
          .order('created_at', ascending: false);

      return response.map((json) => ExpenseModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch entries: $e');
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      if (expense.id == null) throw Exception('Entry ID is missing');

      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _supabase
          .from('expenses')
          .update(expense.toJson(user.id))
          .eq('id', expense.id as Object)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Failed to update entry: $e');
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _supabase
          .from('expenses')
          .delete()
          .eq('id', expenseId)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Failed to delete entry: $e');
    }
  }

  // ==========================================
  // 🏷️ CATEGORY APIs
  // ==========================================

  Future<List<CategoryModel>> getCategories() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final List<dynamic> response = await _supabase
          .from('categories')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      return response.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<void> addCategory(String name) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _supabase.from('categories').insert({
        'user_id': user.id,
        'name': name,
      });
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _supabase
          .from('categories')
          .delete()
          .eq('id', categoryId)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}
