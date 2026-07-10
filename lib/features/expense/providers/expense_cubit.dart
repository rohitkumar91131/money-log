import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/expense_model.dart';
import '../data/category_model.dart';
import '../data/expense_repository.dart';

// --- STATES ---
abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final List<CategoryModel> categories;

  ExpenseLoaded(this.expenses, this.categories);
}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}

// --- CUBIT ---
class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _repository;

  ExpenseCubit(this._repository) : super(ExpenseInitial());

  Future<void> fetchExpenses() async {
    emit(ExpenseLoading());
    try {
      // Fetch both simultaneously
      final expenses = await _repository.getExpenses();
      final categories = await _repository.getCategories();
      emit(ExpenseLoaded(expenses, categories));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  // --- EXPENSE ACTIONS ---

  Future<void> addNewExpense(ExpenseModel expense) async {
    emit(ExpenseLoading());
    try {
      await _repository.addExpense(expense);
      await fetchExpenses();
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> updateExistingExpense(ExpenseModel expense) async {
    emit(ExpenseLoading());
    try {
      await _repository.updateExpense(expense);
      await fetchExpenses();
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> removeExpense(String expenseId) async {
    emit(ExpenseLoading());
    try {
      await _repository.deleteExpense(expenseId);
      await fetchExpenses();
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  // --- CATEGORY ACTIONS ---

  Future<void> addCustomCategory(String name) async {
    try {
      await _repository.addCategory(name);
      await fetchExpenses();
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> removeCustomCategory(String categoryId) async {
    try {
      await _repository.deleteCategory(categoryId);
      await fetchExpenses();
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}
