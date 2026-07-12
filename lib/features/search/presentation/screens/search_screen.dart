import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 🚀 THE FIX: Corrected import paths
import '../../../expense/providers/expense_cubit.dart';
import '../../providers/search_cubit.dart';
import '../../../expense/presentation/widgets/premium_expense_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final expenseState = context.read<ExpenseCubit>().state;

      if (expenseState is ExpenseLoaded) {
        context.read<SearchCubit>().performSearch(query, expenseState.expenses);
      }
    });
    setState(() {}); // Update the UI to show/hide the clear icon
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Keeps the MainLayout background
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black, size: 28),
          // 🚀 THE FIX: Removed rootScaffold parameter
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search amount, category, notes...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    color: Colors.black54,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            CupertinoIcons.clear_thick,
                            color: Colors.black26,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            context.read<SearchCubit>().clearSearch();
                            setState(() {});
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  );
                }

                if (state is SearchEmpty) {
                  return Center(
                    child: Text(
                      'No results found for "${_searchController.text.trim()}"',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  );
                }

                if (state is SearchLoaded) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.results.length,
                    itemBuilder: (context, index) {
                      return PremiumExpenseCard(expense: state.results[index]);
                    },
                  );
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.search,
                        size: 64,
                        color: Colors.grey[200],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Find your transactions',
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
