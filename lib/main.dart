import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- AUTH IMPORTS ---
import 'package:moneylog/features/auth/data/auth_repository.dart';
import 'package:moneylog/features/auth/providers/auth_cubit.dart';
import 'package:moneylog/features/auth/presentation/screens/auth_screen.dart';

// --- EXPENSE IMPORTS (THE NEW PREMIUM FEATURE) ---
import 'package:moneylog/features/expense/data/expense_repository.dart';
import 'package:moneylog/features/expense/providers/expense_cubit.dart';
import 'package:moneylog/features/expense/presentation/screens/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  print('🛑 [main.dart] Initializing Supabase...');

  // Yahan humne default storage par hi rakha hai (No extra packages needed)
  await supabase.Supabase.initialize(
    url: dotenv.get('SUPABASE_URL') ?? '',
    publishableKey: dotenv.get('SUPABASE_PUBLISHABLE_KEY') ?? '',
  );

  print('✅ [main.dart] Supabase Initialized!');
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
        scaffoldBackgroundColor:
            Colors.grey[50], // Cards ke peeche smooth grey background
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
        print('🔄 [AuthGate Stream] Triggered!');
        final state = snapshot.data;

        if (state == null) {
          print('⚠️ [AuthGate Stream] Snapshot data is null');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        }

        print('📝 [AuthGate Stream] Event: ${state.event}');
        print('📝 [AuthGate Stream] Session exists?: ${state.session != null}');

        final isLoggedIn = state.session != null;

        if (isLoggedIn) {
          print(
            '🚀 [AuthGate Stream] User is Logged In! Routing to Homepage...',
          );
          // Naye ExpenseCubit ko initialize karke fetchExpenses() call kar rahe hain
          return BlocProvider(
            create: (context) =>
                ExpenseCubit(ExpenseRepository())..fetchExpenses(),
            child: const Homepage(),
          );
        }

        print(
          '🔒 [AuthGate Stream] User is NOT Logged In. Routing to AuthScreen...',
        );
        return BlocProvider(
          create: (context) => AuthCubit(AuthRepository()),
          child: const AuthScreen(),
        );
      },
    );
  }
}
