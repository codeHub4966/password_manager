import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as drift;
import '../main.dart';
import '../data/database.dart';
import '../core/encryption_service.dart';
import '../core/password_generator.dart';

class PasswordFormScreen extends StatefulWidget {
  final PasswordEntry? entryToEdit;
  const PasswordFormScreen({super.key, this.entryToEdit});

  @override
  State<PasswordFormScreen> createState() => _PasswordFormScreenState();
}

class _PasswordFormScreenState extends State<PasswordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _siteController = TextEditingController();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _notesController = TextEditingController();
  final _questionController = TextEditingController();
  
  String _selectedCategory = 'Other';
  final List<String> _categories = ['Social', 'Banking', 'Work', 'Personal', 'Other'];

  bool _obscurePassword = true;
  double _passwordStrength = 0.0;
  
  bool get _isEditing => widget.entryToEdit != null;

  // --- NEW VARIABLES FOR DUPLICATE DETECTION ---
  List<PasswordEntry> _allEntries = [];
  bool _isDuplicate = false;

  @override
  void initState() {
    super.initState();
    _loadExistingEntries(); // Load entries when screen opens
    if (_isEditing) {
      final entry = widget.entryToEdit!;
      _siteController.text = entry.siteName;
      _userController.text = entry.username;
      _passController.text = EncryptionService.decryptData(entry.encryptedPassword);
      _notesController.text = entry.notes ?? '';
      _questionController.text = entry.securityQuestion ?? '';
      _selectedCategory = entry.category;
      _evaluatePasswordStrength(_passController.text);
    }
  }

  // --- NEW DUPLICATE DETECTION METHODS ---
  Future<void> _loadExistingEntries() async {
    final entries = await db.select(db.passwordEntries).get();
    if (mounted) {
      setState(() {
        _allEntries = entries;
        // If editing, remove the current entry from the duplicate check list
        if (_isEditing) {
          _allEntries.removeWhere((e) => e.id == widget.entryToEdit!.id);
        }
      });
    }
  }

  void _checkForDuplicate(String value) {
    // Check if the exact site name already exists (case-insensitive)
    final match = _allEntries.where((e) => e.siteName.toLowerCase() == value.toLowerCase());
    setState(() {
      _isDuplicate = match.isNotEmpty;
    });
  }

  void _copyToClipboard(String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard!'), backgroundColor: Colors.green),
      );
    }
  }

  void _evaluatePasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() => _passwordStrength = 0.0);
      return;
    }

    int criteriaMet = 0;
    if (password.length >= 8) criteriaMet++;
    if (password.contains(RegExp(r'[A-Z]'))) criteriaMet++;
    if (password.contains(RegExp(r'[0-9]'))) criteriaMet++;
    if (password.contains(RegExp(r'[!@#\$&*~]'))) criteriaMet++;

    // 3-Tier Backend Logic: Weak (1-2 criteria), Fair (3 criteria), Strong (4 criteria)
    double strength = 0.33; // Default to WEAK
    if (criteriaMet == 3) strength = 0.66; // FAIR
    if (criteriaMet == 4) strength = 1.0; // STRONG

    setState(() => _passwordStrength = strength);
  }

  // --- UPDATED SAVE LOGIC WITH INTERCEPT DIALOG ---
  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      if (_isDuplicate) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF161B22),
            title: const Text('Duplicate Entry', style: TextStyle(color: Colors.white)),
            content: const Text('An entry with this site name already exists. Do you want to save this as a new entry anyway?', style: TextStyle(color: Colors.grey)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text('Cancel', style: TextStyle(color: Colors.grey))
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performSave(isNewAnyway: true);
                }, 
                child: const Text('Save as New Anyway', style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold))
              ),
            ]
          )
        );
      } else {
        _performSave();
      }
    }
  }

  // Separated actual save function (Removed the Update Existing logic)
  void _performSave({bool isNewAnyway = false}) {
    final encryptedPass = EncryptionService.encryptData(_passController.text);
    
    if (_isEditing && !isNewAnyway) {
      // Normal edit behavior
      db.updateEntry(widget.entryToEdit!.copyWith(
        siteName: _siteController.text,
        username: _userController.text,
        encryptedPassword: encryptedPass,
        notes: drift.Value(_notesController.text),
        securityQuestion: drift.Value(_questionController.text),
        category: _selectedCategory,
        lastModified: DateTime.now(),
      ));
    } else {
      // Normal Add New behavior (or Save as New Anyway)
      db.addEntry(PasswordEntriesCompanion.insert(
        siteName: _siteController.text,
        username: _userController.text,
        encryptedPassword: encryptedPass,
        notes: drift.Value(_notesController.text),
        securityQuestion: drift.Value(_questionController.text),
        category: drift.Value(_selectedCategory),
        lastModified: drift.Value(DateTime.now()),
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pop(context)),
        title: Text(_isEditing ? 'Edit Password' : 'New Password', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
        actions: const [Padding(padding: EdgeInsets.only(right: 16.0), child: Icon(Icons.shield_outlined))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Styled Header
              const Text('Entry Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Container(margin: const EdgeInsets.only(top: 4, bottom: 24), height: 2, width: 40, color: Theme.of(context).colorScheme.primary),

              _buildInputLabel('SITE NAME'),
              TextFormField(
                controller: _siteController,
                onChanged: _checkForDuplicate, // Trigger check while typing!
                decoration: const InputDecoration(hintText: 'e.g. Global Bank Corp'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              
              // NEW: Real-time amber warning text!
              if (_isDuplicate)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Text('⚠️ You already have an entry for this.', style: TextStyle(color: Colors.amber, fontSize: 12)),
                ),
                
              const SizedBox(height: 20),

              _buildInputLabel('CATEGORY'),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory, // FIX: Changed 'value' to 'initialValue' to clear the linter warning
                dropdownColor: const Color(0xFF1E232D),
                decoration: const InputDecoration(),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 20),

              _buildInputLabel('USERNAME / EMAIL'),
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(
                  hintText: 'j.doe_secure@email.com',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              // Custom Generator Box Area
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('GENERATED PASSWORD'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _passController,
                            obscureText: _obscurePassword,
                            onChanged: _evaluatePasswordStrength,
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            decoration: InputDecoration(
                              fillColor: const Color(0xFF1E232D),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.copy, color: Colors.grey),
                                    onPressed: () => _copyToClipboard(_passController.text),
                                  ),
                                  IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () {
                            final newPass = PasswordGenerator.generatePassword(length: 8);
                            setState(() {
                              _passController.text = newPass;
                              _obscurePassword = false;
                              _evaluatePasswordStrength(newPass);
                            });
                          },
                          child: Container(
                            height: 55, width: 55,
                            decoration: BoxDecoration(color: const Color(0xFF1E232D), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.auto_awesome, color: Color(0xFF00E5FF)),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInputLabel('STRENGTH'),
                        Row(
                          children: [
                            Icon(Icons.shield, size: 12, color: _passwordStrength > 0.33 ? const Color(0xFF00E5FF) : Colors.red),
                            const SizedBox(width: 4),
                            Text(
                              _passwordStrength <= 0.33 ? 'WEAK' : _passwordStrength <= 0.66 ? 'FAIR' : 'STRONG',
                              style: TextStyle(
                                color: _passwordStrength > 0.33 ? const Color(0xFF00E5FF) : Colors.red, 
                                fontSize: 10, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Segmented UI Bar
                    Row(
                      children: List.generate(3, (index) { 
                        // Calculate how many bars to fill based on the WEAK/FAIR/STRONG logic
                        int filledBars = _passController.text.isEmpty ? 0 : 
                                         _passwordStrength <= 0.33 ? 1 : 
                                         _passwordStrength <= 0.66 ? 2 : 3;
                                         
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 4,
                            decoration: BoxDecoration(
                              color: index < filledBars ? const Color(0xFF00E5FF) : Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildInputLabel('SECURITY QUESTION'),
              TextFormField(controller: _questionController, decoration: const InputDecoration(hintText: 'Question or Hint')),
              const SizedBox(height: 20),

              _buildInputLabel('NOTES'),
              TextFormField(controller: _notesController, maxLines: 3, decoration: const InputDecoration(hintText: 'Add private details...')),
              
              const SizedBox(height: 40),
              
              // Full-width Gradient Save Button
              InkWell(
                onTap: _saveEntry,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(colors: [Color(0xFF00B4D8), Color(0xFF0077B6)]),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Save Password', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
      ),
    );
  }
}