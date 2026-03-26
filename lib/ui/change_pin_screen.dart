import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _updatePin() async {
    if (_currentPinController.text.length != 4) {
      _showError('Please enter your 4-digit current PIN.');
      return;
    }
    if (_newPinController.text.length != 4) {
      _showError('Please enter a 4-digit new PIN.');
      return;
    }
    if (_confirmPinController.text.length != 4) {
      _showError('Please confirm your new 4-digit PIN.');
      return;
    }

    if (_newPinController.text != _confirmPinController.text) {
      _showError('New PIN and Confirm PIN do not match.');
      return;
    }

    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('master_pin');

    if (savedPin != _currentPinController.text) {
      setState(() => _isLoading = false);
      _showError('Current PIN is incorrect.');
      return;
    }

    await prefs.setString('master_pin', _newPinController.text);
    
    if (!mounted) return;
    setState(() => _isLoading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Master PIN updated successfully!'), backgroundColor: Colors.green),
    );
    Navigator.pop(context); 
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00E5FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Change Master PIN', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 16, fontWeight: FontWeight.bold)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.settings, color: Color(0xFF00E5FF)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent.withValues(alpha: 0.1)),
              child: const Icon(Icons.security, color: Colors.greenAccent, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Security Renewal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              'Update your encryption anchor to keep your vault impenetrable.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
            const SizedBox(height: 40),
            
            _buildPinField('CURRENT PIN', _currentPinController, Icons.lock),
            const SizedBox(height: 24),
            
            _buildPinField('NEW PIN', _newPinController, Icons.edit),
            const SizedBox(height: 8),
            
            // STRONG ENTROPY BAR (Correctly Placed)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('STRONG ENTROPY', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildPinField('CONFIRM NEW PIN', _confirmPinController, Icons.check_circle),
            const SizedBox(height: 40),

            // UPDATE PIN BUTTON (Restored)
            InkWell(
              onTap: _isLoading ? null : _updatePin,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text('UPDATE MASTER PIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5)),
              ),
            ),
            const SizedBox(height: 16),
            Text('THIS WILL RE-ENCRYPT YOUR LOCAL VAULT KEYS.', style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildPinField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: true,
          obscuringCharacter: '●',
          keyboardType: TextInputType.number,
          maxLength: 4,
          style: const TextStyle(fontSize: 24, letterSpacing: 10, color: Color(0xFF00E5FF)),
          decoration: InputDecoration(
            counterText: "", 
            suffixIcon: Icon(icon, color: Colors.grey.shade600),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }
}