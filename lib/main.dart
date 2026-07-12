import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 🚀 NAYA IMPORT: Hive for Local Database
import 'package:hive_flutter/hive_flutter.dart';

import 'package:moneylog/features/auth/data/auth_repository.dart';
import 'package:moneylog/features/auth/providers/auth_cubit.dart';
import 'package:moneylog/features/auth/presentation/screens/auth_screen.dart';
import 'package:moneylog/features/layout/presentation/screens/main_layout.dart';
import 'package:moneylog/features/expense/data/expense_repository.dart';
import 'package:moneylog/features/expense/providers/expense_cubit.dart';
import 'package:moneylog/features/profile/data/profile_repository.dart';
import 'package:moneylog/features/profile/providers/profile_cubit.dart';
import 'package:moneylog/features/search/providers/search_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 MAGIC: Initialize Local Database before anything else
  await Hive.initFlutter();
  await Hive.openBox('expenses_box'); // Saves your data locally
  await Hive.openBox('sync_queue_box'); // Remembers what to upload when offline

  await dotenv.load();
  await supabase.Supabase.initialize(
    url: dotenv.get('SUPABASE_URL') ?? '',
    publishableKey: dotenv.get('SUPABASE_PUBLISHABLE_KEY') ?? '',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Log',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = supabase.Supabase.instance.client.auth;

    return StreamBuilder<supabase.AuthState>(
      stream: auth.onAuthStateChange,
      initialData: supabase.AuthState(
        supabase.AuthChangeEvent.initialSession,
        auth.currentSession,
      ),
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        }

        final isLoggedIn = state.session != null;

        if (isLoggedIn) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) =>
                    ExpenseCubit(ExpenseRepository())..fetchExpenses(),
              ),
              BlocProvider(
                create: (context) =>
                    ProfileCubit(ProfileRepository())..loadProfile(),
              ),
              BlocProvider(create: (context) => SearchCubit()),
            ],
            child: const MainLayout(),
          );
        }

        return BlocProvider(
          create: (context) => AuthCubit(AuthRepository()),
          child: const AuthScreen(),
        );
      },
    );
  }
}
