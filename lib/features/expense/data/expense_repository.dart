import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'expense_model.dart';
import 'category_model.dart';

class ExpenseRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Box _expenseBox = Hive.box('expenses_box');
  final Box _syncQueueBox = Hive.box('sync_queue_box'); // 🚀 The Waiting Room
  final Uuid _uuid = const Uuid();

  // 1. INSTANT LOCAL READ
  List<ExpenseModel> getLocalExpenses() {
    final localData = _expenseBox.values.toList();
    List<ExpenseModel> expenses = localData
        .map((json) => ExpenseModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    expenses.sort((a, b) => b.entryDate.compareTo(a.entryDate));
    return expenses;
  }

  // 2. PROCESS OFFLINE QUEUE (Push local changes to cloud)
  Future<void> _processSyncQueue() async {
    final user = _supabase.auth.currentUser;
    if (user == null || _syncQueueBox.isEmpty) return;

    final keys = _syncQueueBox.keys.toList();
    for (var key in keys) {
      final item = _syncQueueBox.get(key);
      try {
        if (item['action'] == 'ADD') {
          await _supabase.from('expenses').insert(item['data']);
        } else if (item['action'] == 'UPDATE') {
          await _supabase
              .from('expenses')
              .update(item['data'])
              .eq('id', key)
              .eq('user_id', user.id);
        } else if (item['action'] == 'DELETE') {
          await _supabase
              .from('expenses')
              .delete()
              .eq('id', key)
              .eq('user_id', user.id);
        }
        // If successful, remove it from the waiting room
        await _syncQueueBox.delete(key);
      } catch (e) {
        // If it fails (still offline), break the loop and keep it in the queue for later
        throw Exception('Still offline, stopping queue.');
      }
    }
  }

  // 3. EXPLICIT CLOUD SYNC (Pulls latest data AFTER pushing offline changes)
  Future<void> syncExpensesFromCloud() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // 🚀 STEP A: Upload offline changes first!
    await _processSyncQueue();

    // 🚀 STEP B: Fetch fresh data from Supabase
    final List<dynamic> response = await _supabase
        .from('expenses')
        .select()
        .eq('user_id', user.id);

    // Completely refresh local database with exact cloud state
    await _expenseBox.clear();
    for (var item in response) {
      await _expenseBox.put(item['id'].toString(), item);
    }
  }

  // --- WRITE APIs ---
  Future<void> addExpense(ExpenseModel expense) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final String expenseId = expense.id ?? _uuid.v4();
    final DateTime createdAt = expense.createdAt ?? DateTime.now();

    final Map<String, dynamic> expenseJson = expense.toJson(user.id);
    expenseJson['id'] = expenseId;
    expenseJson['created_at'] = createdAt.toIso8601String();

    // 1. Instant local write
    await _expenseBox.put(expenseId, expenseJson);

    // 2. Add to Queue
    await _syncQueueBox.put(expenseId, {'action': 'ADD', 'data': expenseJson});

    // 3. Try to push silently in background
    _processSyncQueue().catchError(
      (_) => print('Offline Mode: Added to sync queue.'),
    );
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    if (expense.id == null) return;
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final Map<String, dynamic> expenseJson = expense.toJson(user.id);
    expenseJson['id'] = expense.id;
    if (expense.createdAt != null) {
      expenseJson['created_at'] = expense.createdAt!.toIso8601String();
    }

    // 1. Instant local update
    await _expenseBox.put(expense.id, expenseJson);

    // 2. Add to Queue
    await _syncQueueBox.put(expense.id, {
      'action': 'UPDATE',
      'data': expenseJson,
    });

    // 3. Try to push silently
    _processSyncQueue().catchError(
      (_) => print('Offline Mode: Update added to queue.'),
    );
  }

  Future<void> deleteExpense(String expenseId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // 1. Instant local delete
    await _expenseBox.delete(expenseId);

    // 2. Add to Queue
    await _syncQueueBox.put(expenseId, {'action': 'DELETE', 'data': null});

    // 3. Try to push silently
    _processSyncQueue().catchError(
      (_) => print('Offline Mode: Delete added to queue.'),
    );
  }

  // --- CATEGORIES (Standard) ---
  Future<List<CategoryModel>> getCategories() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final response = await _supabase
        .from('categories')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: true);
    return response.map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<void> addCategory(String name) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    await _supabase.from('categories').insert({
      'user_id': user.id,
      'name': name,
    });
  }

  Future<void> deleteCategory(String categoryId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    await _supabase
        .from('categories')
        .delete()
        .eq('id', categoryId)
        .eq('user_id', user.id);
  }
}
