import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // ADD THIS IMPORT to access your database
import 'home_screen.dart';

// Defines the current state of the login screen
enum AuthState { loading, create, confirm, authenticate }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthState _authState = AuthState.loading;
  String _enteredPin = "";
  String _tempPin = ""; // Used to store the first PIN during the "Confirm" step
  String _masterPin = "";

  @override
  void initState() {
    super.initState();
    _loadSavedPin();
  }

  // Checks if the user has already registered a PIN on this device
  Future<void> _loadSavedPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('master_pin');
    
    setState(() {
      if (savedPin != null && savedPin.isNotEmpty) {
        _masterPin = savedPin;
        _authState = AuthState.authenticate; // PIN exists, ask them to log in
      } else {
        _authState = AuthState.create; // No PIN exists, prompt registration
      }
    });
  }

  // Saves the newly created PIN to local device storage
  Future<void> _savePinAndLogin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('master_pin', pin);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _onNumPressed(String num) {
    if (_enteredPin.length < 4) {
      setState(() => _enteredPin += num);
      if (_enteredPin.length == 4) {
        // Auto-verify when 4 digits are entered
        Future.delayed(const Duration(milliseconds: 200), _processPinEntry);
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
    }
  }

  // Handles the logic depending on what step the user is on
  void _processPinEntry() {
    if (_authState == AuthState.create) {
      // Step 1: User typed a new PIN, now ask them to confirm it
      setState(() {
        _tempPin = _enteredPin;
        _enteredPin = "";
        _authState = AuthState.confirm;
      });
    } else if (_authState == AuthState.confirm) {
      // Step 2: User is confirming the new PIN
      if (_enteredPin == _tempPin) {
        _savePinAndLogin(_enteredPin); // Success! Save and log in.
      } else {
        // Fail: PINs didn't match. Reset and make them try again.
        setState(() {
          _enteredPin = "";
          _tempPin = "";
          _authState = AuthState.create;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PINs do not match. Try again.'), backgroundColor: Colors.redAccent),
        );
      }
    } else if (_authState == AuthState.authenticate) {
      // Step 3: Normal Login
      if (_enteredPin == _masterPin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        setState(() => _enteredPin = ""); // Clear on fail
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect Master PIN.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading spinner while checking storage
    if (_authState == AuthState.loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E17),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))),
      );
    }

    // Dynamic Text based on the current state
    String titleText = "";
    String subtitleText = "";

    switch (_authState) {
      case AuthState.create:
        titleText = "Create Master PIN";
        subtitleText = "Set up your 4-digit security code";
        break;
      case AuthState.confirm:
        titleText = "Confirm Master PIN";
        subtitleText = "Re-enter your 4-digit code to verify";
        break;
      case AuthState.authenticate:
        titleText = "Enter Master PIN";
        subtitleText = "Identity verification required";
        break;
      default:
        break;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Theme.of(context).colorScheme.primary, size: 28),
                      const SizedBox(width: 8),
                      const Text('Password Box', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(Icons.lock, color: Colors.greenAccent, size: 14),
                      SizedBox(width: 4),
                      Text('SECURE SESSION', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
            const Spacer(),
            
            // Dynamic Title & Subtitle
            Text(titleText, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w300, color: Colors.white)),
            const SizedBox(height: 8),
            Text(subtitleText, style: TextStyle(color: Colors.grey.shade400)),
            const SizedBox(height: 40),
            
            // PIN Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade600, width: 2),
                    color: index < _enteredPin.length ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  ),
                );
              }),
            ),
            
            const Spacer(),
            
            // Custom Keypad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  _buildKeypadRow(['4', '5', '6']),
                  _buildKeypadRow(['7', '8', '9']),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 80, height: 80), 
                      _buildKeypadButton('0'),
                      _buildKeypadButton(Icons.backspace_outlined, isIcon: true, onTap: _onBackspace),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            
            // Footer Badges
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF161B22),
                    title: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Reset App & PIN?', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    content: const Text(
                      'If you forgot your PIN, you must reset the app to create a new one.\n\nWARNING: Resetting your PIN will permanently delete ALL your saved passwords and credentials. This strict security measure is designed to protect your sensitive data. This action cannot be undone.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.justify,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () async {
                          // 1. Delete the saved Master PIN from device storage
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('master_pin');
                          
                          // 2. Wipe the entire SQLite database (Deletes all passwords)
                          await db.delete(db.passwordEntries).go();
                          
                          // 3. FIX: Re-seed the initial mock data to simulate "first download" state!
                          await db.seedInitialData();
                          
                          if (!context.mounted) return;
                          Navigator.pop(context); // Close the dialog
                          
                          // 4. Reset the UI back to "Create Master PIN" mode
                          setState(() {
                            _masterPin = "";
                            _enteredPin = "";
                            _tempPin = "";
                            _authState = AuthState.create;
                          });
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vault reset complete. Create a new PIN.'), 
                              backgroundColor: Colors.redAccent
                            )
                          );
                        },
                        child: const Text('ERASE & RESET', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
              child: Text('FORGOT PIN?', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                  SizedBox(width: 8),
                  Text('APP IS ENCRYPTED WITH AES-256', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((n) => _buildKeypadButton(n)).toList(),
    );
  }

  Widget _buildKeypadButton(dynamic content, {bool isIcon = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? (isIcon ? () {} : () => _onNumPressed(content)),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        child: isIcon
            ? Icon(content as IconData, color: Colors.grey.shade400, size: 28)
            : Text(content as String, style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w400)),
      ),
    );
  }
}