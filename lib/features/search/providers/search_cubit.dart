import 'package:flutter_bloc/flutter_bloc.dart';
import '../../expense/data/expense_model.dart';

// --- STATES ---
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<ExpenseModel> results;
  SearchLoaded(this.results);
}

class SearchEmpty extends SearchState {}

// --- CUBIT ---
class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  void performSearch(String query, List<ExpenseModel> allExpenses) {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    // Tiny delay to make the UI feel smooth and natural
    Future.delayed(const Duration(milliseconds: 300), () {
      final lowerQuery = query.toLowerCase().trim();

      final results = allExpenses.where((expense) {
        final nameMatch = expense.name.toLowerCase().contains(lowerQuery);
        final amountMatch = expense.amount.toString().contains(lowerQuery);
        final typeMatch = expense.expenseType.toLowerCase().contains(
          lowerQuery,
        );
        final categoryMatch = expense.category.toLowerCase().contains(
          lowerQuery,
        );
        final notesMatch = (expense.notes ?? '').toLowerCase().contains(
          lowerQuery,
        );

        return nameMatch ||
            amountMatch ||
            typeMatch ||
            categoryMatch ||
            notesMatch;
      }).toList();

      if (results.isEmpty) {
        emit(SearchEmpty());
      } else {
        emit(SearchLoaded(results));
      }
    });
  }

  void clearSearch() {
    emit(SearchInitial());
  }
}
