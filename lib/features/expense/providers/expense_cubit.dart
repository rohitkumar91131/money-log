import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/expense_model.dart';
import '../data/category_model.dart';
import '../data/expense_repository.dart';

enum SyncStatus { idle, Syncing, error }

abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final List<CategoryModel> categories;
  final SyncStatus syncStatus;
  final bool isOffline; // 🚀 NAYA: Track if we are still offline

  ExpenseLoaded(
    this.expenses,
    this.categories, {
    this.syncStatus = SyncStatus.idle,
    this.isOffline = false,
  });
}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _repository;

  ExpenseCubit(this._repository) : super(ExpenseInitial());

  Future<void> fetchExpenses() async {
    final localExpenses = _repository.getLocalExpenses();
    List<CategoryModel> localCategories = [];

    emit(
      ExpenseLoaded(
        localExpenses,
        localCategories,
        syncStatus: SyncStatus.Syncing,
      ),
    );

    try {
      localCategories = await _repository.getCategories();
      await _repository.syncExpensesFromCloud();
      final syncedExpenses = _repository.getLocalExpenses();

      emit(
        ExpenseLoaded(
          syncedExpenses,
          localCategories,
          syncStatus: SyncStatus.idle,
          isOffline: false,
        ),
      );
    } catch (e) {
      final currentExpenses = _repository.getLocalExpenses();

      // 1. Show "Offline Mode" immediately
      emit(
        ExpenseLoaded(
          currentExpenses,
          localCategories,
          syncStatus: SyncStatus.error,
          isOffline: true,
        ),
      );

      // 2. Wait for 2.5 seconds (Telegram style)
      await Future.delayed(const Duration(milliseconds: 2500));

      // 3. Slide back to normal title, but keep the offline flag true
      if (!isClosed) {
        emit(
          ExpenseLoaded(
            currentExpenses,
            localCategories,
            syncStatus: SyncStatus.idle,
            isOffline: true,
          ),
        );
      }
    }
  }

  Future<void> addNewExpense(ExpenseModel expense) async {
    await _repository.addExpense(expense);
    await fetchExpenses();
  }

  Future<void> updateExistingExpense(ExpenseModel expense) async {
    await _repository.updateExpense(expense);
    await fetchExpenses();
  }

  Future<void> removeExpense(String expenseId) async {
    await _repository.deleteExpense(expenseId);
    await fetchExpenses();
  }

  Future<void> addCustomCategory(String name) async {
    await _repository.addCategory(name);
    await fetchExpenses();
  }

  Future<void> removeCustomCategory(String categoryId) async {
    await _repository.deleteCategory(categoryId);
    await fetchExpenses();
  }
}
