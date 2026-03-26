import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import '../main.dart';
import '../data/database.dart';
import 'change_pin_screen.dart';
import 'home_screen.dart';
import 'security_analysis_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isAutoLockEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAutoLockEnabled = prefs.getBool('auto_lock_enabled') ?? false;
    });
  }

  Future<void> _exportData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Export Vault Backup', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to copy your entire vault to your clipboard as an encrypted JSON backup?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Confirm', style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirm != true) return;

    final entries = await db.select(db.passwordEntries).get();
    
    final List<Map<String, dynamic>> jsonList = entries.map((e) => {
      'siteName': e.siteName,
      'username': e.username,
      'encryptedPassword': e.encryptedPassword,
      'notes': e.notes,
      'securityQuestion': e.securityQuestion,
      'category': e.category,
      'lastModified': e.lastModified.toIso8601String(),
    }).toList();
    
    final jsonString = jsonEncode(jsonList);
    
    await Clipboard.setData(ClipboardData(text: jsonString));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vault backup copied to clipboard!'), backgroundColor: Colors.green));
  }

  Future<void> _importData() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Import Vault Backup', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLines: 5,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Paste JSON backup data here...', 
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: const Color(0xFF1E232D),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              final text = controller.text;
              // FIX: Close the dialog BEFORE starting the async database work
              Navigator.pop(dialogContext); 
              
              try {
                final decoded = jsonDecode(text);
                if (decoded is! List) throw Exception('Format error');
                
                int count = 0;
                for (var item in decoded) {
                   final entry = PasswordEntriesCompanion.insert(
                     siteName: item['siteName'] ?? 'Unknown',
                     username: item['username'] ?? '',
                     encryptedPassword: item['encryptedPassword'] ?? '',
                     notes: drift.Value(item['notes']),
                     securityQuestion: drift.Value(item['securityQuestion']),
                     category: drift.Value(item['category'] ?? 'Other'),
                     lastModified: drift.Value(item['lastModified'] != null ? DateTime.parse(item['lastModified']) : DateTime.now()),
                   );
                   await db.addEntry(entry);
                   count++;
                }
                
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$count entries imported successfully!'), backgroundColor: Colors.green));
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Invalid JSON backup data.'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Import Data', style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: const Text('Vault Sentinel', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: _buildBottomNav(context, 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Settings', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Manage your obsidian-grade security parameters.', style: TextStyle(fontSize: 14, color: Colors.grey.shade400, height: 1.5)),
            const SizedBox(height: 40),
            
            Text('CONFIGURATION', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            
            Container(
              decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildSettingsTile(
                    context,
                    title: 'Change Master PIN',
                    subtitle: 'Update your primary access code',
                    icon: Icons.pin,
                    iconColor: Colors.tealAccent.shade400,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePinScreen())),
                  ),
                  Divider(color: Colors.grey.shade800, height: 1, indent: 70),
                  
                  _buildSettingsTile(
                    context,
                    title: 'Auto-Lock Timer',
                    subtitle: _isAutoLockEnabled ? 'Locked after 30s of inactivity' : 'Auto-lock is disabled',
                    icon: Icons.timer,
                    iconColor: Colors.blueAccent.shade200,
                    trailing: Switch(
                      value: _isAutoLockEnabled,
                      activeThumbColor: const Color(0xFF00E5FF), // FIX: Replaced activeColor
                      activeTrackColor: const Color(0xFF00E5FF).withValues(alpha: 0.4), // FIX: Replaced withOpacity
                      onChanged: (val) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('auto_lock_enabled', val);
                        setState(() => _isAutoLockEnabled = val);
                      },
                    ),
                    onTap: () async {
                       final val = !_isAutoLockEnabled;
                       final prefs = await SharedPreferences.getInstance();
                       await prefs.setBool('auto_lock_enabled', val);
                       setState(() => _isAutoLockEnabled = val);
                    },
                  ),
                  Divider(color: Colors.grey.shade800, height: 1, indent: 70),
                  
                  _buildSettingsTile(
                    context,
                    title: 'Export Vault Backup',
                    subtitle: 'Copy Encrypted JSON to Clipboard',
                    icon: Icons.upload_file,
                    iconColor: Colors.grey.shade400,
                    onTap: _exportData,
                  ),
                  Divider(color: Colors.grey.shade800, height: 1, indent: 70),
                  
                  _buildSettingsTile(
                    context,
                    title: 'Import Vault Backup',
                    subtitle: 'Restore from JSON Backup',
                    icon: Icons.download,
                    iconColor: Colors.greenAccent.shade400,
                    onTap: _importData,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color iconColor, Widget? trailing, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFF1E232D), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey.shade600),
      onTap: onTap,
    );
  }

  // Shared Bottom Navigation Bar Builder
  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold);
          return const TextStyle(color: Colors.grey, fontSize: 12);
        }),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        backgroundColor: const Color(0xFF0A0E17),
        indicatorColor: const Color(0xFF00E5FF).withValues(alpha: 0.2), // FIX: Replaced withOpacity
        destinations: const [
          NavigationDestination(icon: Icon(Icons.lock_outline, color: Colors.grey), selectedIcon: Icon(Icons.lock, color: Color(0xFF00E5FF)), label: 'Vault'),
          NavigationDestination(icon: Icon(Icons.shield_outlined, color: Colors.grey), selectedIcon: Icon(Icons.shield, color: Color(0xFF00E5FF)), label: 'Security'),
          NavigationDestination(icon: Icon(Icons.settings_outlined, color: Colors.grey), selectedIcon: Icon(Icons.settings, color: Color(0xFF00E5FF)), label: 'Settings'),
        ],
        onDestinationSelected: (index) {
          if (index == currentIndex) return;
          Widget page = index == 0 ? const HomeScreen() : index == 1 ? const SecurityAnalysisScreen() : const SettingsScreen();
          // FIX: Replaced underscores with specific variable names
          Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => page, transitionDuration: Duration.zero));
        },
      ),
    );
  }
}