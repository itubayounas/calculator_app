import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/app_user.dart';
import 'screens/calculator_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/history_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Colors.indigo;

    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // follows the phone's light/dark setting
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// The single listener at the app root: signed out -> login, signed in -> calculator.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  final HistoryService _historyService = HistoryService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null) {
          return LoginScreen(authService: _authService);
        }
        return CalculatorScreen(
          key: ValueKey(user.uid),
          user: user,
          authService: _authService,
          historyService: _historyService,
        );
      },
    );
  }
}
