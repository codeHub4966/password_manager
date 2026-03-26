import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/database.dart';
import 'ui/login_screen.dart';

late final AppDatabase db;

// Global navigator key allows us to navigate to the LoginScreen from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  db = AppDatabase();
  await db.seedInitialData();
  runApp(const PasswordManagerApp());
}

class PasswordManagerApp extends StatelessWidget {
  const PasswordManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Password Box',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          surface: Color(0xFF161B22),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Color(0xFF00E5FF)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E232D),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIconColor: Colors.grey,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF161B22),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      // We wrap the entire app's routing inside our new GlobalAuthWrapper
      builder: (context, child) {
        return GlobalAuthWrapper(child: child!);
      },
      home: const LoginScreen(),
    );
  }
}

// --- GLOBAL AUTO-LOCK WRAPPER ---
class GlobalAuthWrapper extends StatefulWidget {
  final Widget child;
  const GlobalAuthWrapper({super.key, required this.child});

  @override
  State<GlobalAuthWrapper> createState() => _GlobalAuthWrapperState();
}

class _GlobalAuthWrapperState extends State<GlobalAuthWrapper> with WidgetsBindingObserver {
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startInactivityTimer();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 30), () async {
      // Whenever the timer completes, it checks if Auto-Lock is enabled in settings
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('auto_lock_enabled') ?? false; // FIX: Default is now off
      if (isEnabled) {
        _lockApp();
      }
    });
  }

  void _handleUserInteraction(_) {
    // Any touch anywhere in the app resets the timer
    _startInactivityTimer();
  }

  void _lockApp() {
    _inactivityTimer?.cancel();
    // Use the global key to forcefully push the LoginScreen on top of whatever you were doing
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // FIX: If minimized, lock immediately. Do NOT check the toggle settings!
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
       _lockApp();
    } else if (state == AppLifecycleState.resumed) {
       _startInactivityTimer(); // Restart the 30s timer when reopened
    }
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The Listener wraps the ENTIRE application screen space
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handleUserInteraction,
      onPointerMove: _handleUserInteraction,
      onPointerUp: _handleUserInteraction,
      child: widget.child,
    );
  }
}