import 'package:flutter/material.dart';
import '../main.dart';
import '../data/database.dart';
import '../core/encryption_service.dart';
import 'password_form_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'security_analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Social', 'Banking', 'Work', 'Personal', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNav(context, 0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.lock, color: Colors.white),
                        onPressed: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Secure Core', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w300, color: Colors.white)),
                  const SizedBox(height: 4),
                  StreamBuilder<List<PasswordEntry>>(
                    stream: db.watchAllEntries(),
                    builder: (context, snapshot) {
                      int count = snapshot.data?.length ?? 0;
                      return Text('Managing $count encrypted credentials', style: TextStyle(color: Colors.grey.shade400, fontSize: 14));
                    }
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search....',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              ),
            ),
          
            // Category Filter Chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primary : const Color(0xFF1E232D),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey.shade400,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            
            // Credentials List
            Expanded(
              child: StreamBuilder<List<PasswordEntry>>(
                stream: db.watchAllEntries(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  
                  var entries = snapshot.data ?? [];
                  if (_searchQuery.isNotEmpty) {
                    entries = entries.where((e) => 
                      e.siteName.toLowerCase().contains(_searchQuery) || 
                      e.username.toLowerCase().contains(_searchQuery) ||
                      (e.notes?.toLowerCase().contains(_searchQuery) ?? false) ||
                      (e.securityQuestion?.toLowerCase().contains(_searchQuery) ?? false) ||
                      e.category.toLowerCase().contains(_searchQuery)
                    ).toList();
                  }
                  if (_selectedCategory != 'All') entries = entries.where((e) => e.category == _selectedCategory).toList();

                  if (entries.isEmpty) return const Center(child: Text('No results found.', style: TextStyle(color: Colors.grey)));

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    itemCount: entries.length,
                    itemBuilder: (context, index) => _buildEntryCard(context, entries[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PasswordFormScreen())),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // INDIVIDUAL PASSWORD CARD
  Widget _buildEntryCard(BuildContext context, PasswordEntry entry) {
    bool isVisible = false;

    return StatefulBuilder(
      builder: (context, setCardState) {
        final pass = EncryptionService.decryptData(entry.encryptedPassword);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: Key(entry.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (dir) => _showDeleteConfirm(context, entry),
            onDismissed: (_) => db.deleteEntry(entry),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF1E232D), borderRadius: BorderRadius.circular(12)),
                child: Icon(_getCategoryIcon(entry.category), color: Theme.of(context).colorScheme.primary, size: 24),
              ),
              title: Text(entry.siteName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(entry.username, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    isVisible ? pass : '••••••••',
                    style: TextStyle(
                      color: isVisible ? const Color(0xFF00E5FF) : Colors.grey.shade600,
                      fontSize: 13,
                      letterSpacing: isVisible ? 0.5 : 2,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.grey),
                    onPressed: () => setCardState(() => isVisible = !isVisible),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    onPressed: () async {
                      if (await _showDeleteConfirm(context, entry) == true) db.deleteEntry(entry);
                    },
                  ),
                ],
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PasswordFormScreen(entryToEdit: entry))),
            ),
          ),
        );
      }
    );
  }

  Future<bool?> _showDeleteConfirm(BuildContext context, PasswordEntry entry) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Delete Entry?', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete ${entry.siteName}? This cannot be undone.', style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Social': return Icons.share;
      case 'Banking': return Icons.account_balance;
      case 'Work': return Icons.work;
      case 'Personal': return Icons.person;
      default: return Icons.vpn_key;
    }
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
        indicatorColor: const Color(0xFF00E5FF).withValues(alpha: 0.2), 
        destinations: const [
          NavigationDestination(icon: Icon(Icons.lock_outline, color: Colors.grey), selectedIcon: Icon(Icons.lock, color: Color(0xFF00E5FF)), label: 'Vault'),
          NavigationDestination(icon: Icon(Icons.shield_outlined, color: Colors.grey), selectedIcon: Icon(Icons.shield, color: Color(0xFF00E5FF)), label: 'Security'),
          NavigationDestination(icon: Icon(Icons.settings_outlined, color: Colors.grey), selectedIcon: Icon(Icons.settings, color: Color(0xFF00E5FF)), label: 'Settings'),
        ],
        onDestinationSelected: (index) {
          if (index == currentIndex) return;
          Widget page = index == 0 ? const HomeScreen() : index == 1 ? const SecurityAnalysisScreen() : const SettingsScreen();
          Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => page, transitionDuration: Duration.zero));
        },
      ),
    );
  }
}