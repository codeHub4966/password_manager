import 'package:flutter/material.dart';
import 'dart:math';
import '../main.dart';
import '../data/database.dart'; 
import '../core/encryption_service.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'password_form_screen.dart'; 

class SecurityAnalysisScreen extends StatefulWidget {
  const SecurityAnalysisScreen({super.key});

  @override
  State<SecurityAnalysisScreen> createState() => _SecurityAnalysisScreenState();
}

class _SecurityAnalysisScreenState extends State<SecurityAnalysisScreen> {
  bool _isLoading = true;
  int _weakCount = 0;
  int _fairCount = 0;
  int _strongCount = 0;
  int _totalCount = 0;
  
  List<PasswordEntry> _allEntries = [];

  @override
  void initState() {
    super.initState();
    _analyzePasswords();
  }

  Future<void> _analyzePasswords() async {
    final rawEntries = await db.select(db.passwordEntries).get();
    final entries = rawEntries.toList(); 
    
    // Sort the list from WEAK to FAIR to STRONG
    entries.sort((a, b) {
      int getStrengthScore(String encrypted) {
        final pass = EncryptionService.decryptData(encrypted);
        int c = 0;
        if (pass.length >= 8) c++;
        if (pass.contains(RegExp(r'[A-Z]'))) c++;
        if (pass.contains(RegExp(r'[0-9]'))) c++;
        if (pass.contains(RegExp(r'[!@#\$&*~]'))) c++;
        
        if (c <= 2) return 0; // Weak
        if (c == 3) return 1; // Fair
        return 2; // Strong
      }
      return getStrengthScore(a.encryptedPassword).compareTo(getStrengthScore(b.encryptedPassword));
    });

    int weak = 0, fair = 0, strong = 0;

    for (var entry in entries) {
      final pass = EncryptionService.decryptData(entry.encryptedPassword);
      
      int criteriaMet = 0;
      if (pass.length >= 8) criteriaMet++;
      if (pass.contains(RegExp(r'[A-Z]'))) criteriaMet++;
      if (pass.contains(RegExp(r'[0-9]'))) criteriaMet++;
      if (pass.contains(RegExp(r'[!@#\$&*~]'))) criteriaMet++;

      if (criteriaMet <= 2) {
        weak++;
      } else if (criteriaMet == 3) {
        fair++;
      } else {
        strong++;
      }
    }

    setState(() {
      _weakCount = weak;
      _fairCount = fair;
      _strongCount = strong;
      _totalCount = entries.length;
      _allEntries = entries;
      _isLoading = false;
    });
  }

  // FIX: Updated to a weighted average so Fair passwords contribute to the score!
  int get _securePercentage {
    if (_totalCount == 0) return 0;
    
    // Calculate total vault score based on our 3-tier math:
    // Weak = 33%, Fair = 66%, Strong = 100%
    double totalScore = (_weakCount * 0.33) + (_fairCount * 0.66) + (_strongCount * 1.0);
    
    return ((totalScore / _totalCount) * 100).round();
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return 'Last changed ${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return 'Last changed ${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return 'Last changed ${diff.inDays}d ago';
    if (diff.inHours > 0) return 'Last changed ${diff.inHours}h ago';
    if (diff.inMinutes > 0) return 'Last changed ${diff.inMinutes}m ago';
    return 'Last changed just now';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Social': return Icons.share;
      case 'Banking': return Icons.account_balance;
      case 'Work': return Icons.work;
      case 'Personal': return Icons.person;
      default: return Icons.language;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: const Text('Security Analysis', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: _buildBottomNav(context, 1),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Donut Chart Area
                  SizedBox(
                    height: 220,
                    width: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(220, 220),
                          painter: DonutChartPainter(
                            weak: _weakCount,
                            fair: _fairCount,
                            strong: _strongCount,
                            total: _totalCount,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$_securePercentage%', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                            const Text('SECURE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Detail Cards Reordered: Weak -> Fair -> Strong
                  _buildLegendCard('Weak / Compromised', _weakCount, Colors.redAccent),
                  const SizedBox(height: 12),
                  _buildLegendCard('Fair Strength', _fairCount, const Color(0xFF00E5FF)),
                  const SizedBox(height: 12),
                  _buildLegendCard('Strong Passwords', _strongCount, Colors.greenAccent),
                  
                  const SizedBox(height: 40),
                  
                  // Detailed Breakdown Section
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Detailed Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _allEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _allEntries[index];
                      final pass = EncryptionService.decryptData(entry.encryptedPassword);
                      
                      int criteriaMet = 0;
                      if (pass.length >= 8) criteriaMet++;
                      if (pass.contains(RegExp(r'[A-Z]'))) criteriaMet++;
                      if (pass.contains(RegExp(r'[0-9]'))) criteriaMet++;
                      if (pass.contains(RegExp(r'[!@#\$&*~]'))) criteriaMet++;

                      String strengthText;
                      Color strengthColor;
                      Color strengthBg;
                      
                      if (criteriaMet <= 2) {
                        strengthText = 'WEAK';
                        strengthColor = Colors.redAccent;
                        // FIX: Updated to withValues(alpha: ...) to resolve deprecation and positional arguments
                        strengthBg = Colors.redAccent.withValues(alpha: 0.1); 
                      } else if (criteriaMet == 3) {
                        strengthText = 'FAIR';
                        strengthColor = Colors.amber;
                        strengthBg = Colors.amber.withValues(alpha: 0.1);
                      } else {
                        strengthText = 'STRONG';
                        strengthColor = Colors.greenAccent;
                        strengthBg = Colors.greenAccent.withValues(alpha: 0.1);
                      }

                      return GestureDetector(
                        onTap: () async {
                          // FIX: Wait for the user to return from the edit screen, then refresh!
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => PasswordFormScreen(entryToEdit: entry)));
                          _analyzePasswords();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFF1E232D), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(color: Color(0xFF161B22), shape: BoxShape.circle),
                                child: Icon(_getCategoryIcon(entry.category), color: Colors.grey.shade500, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.siteName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(_formatTimeAgo(entry.lastModified), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: strengthBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: strengthColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(strengthText, style: TextStyle(color: strengthColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildLegendCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: const Color(0xFF1E232D), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.circle, size: 12, color: color),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(count.toString(), style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
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
        indicatorColor: const Color(0xFF00E5FF).withValues(alpha: 0.2), // FIX: Updated deprecation
        destinations: const [
          NavigationDestination(icon: Icon(Icons.lock_outline, color: Colors.grey), selectedIcon: Icon(Icons.lock, color: Color(0xFF00E5FF)), label: 'Vault'),
          NavigationDestination(icon: Icon(Icons.shield_outlined, color: Colors.grey), selectedIcon: Icon(Icons.shield, color: Color(0xFF00E5FF)), label: 'Security'),
          NavigationDestination(icon: Icon(Icons.settings_outlined, color: Colors.grey), selectedIcon: Icon(Icons.settings, color: Color(0xFF00E5FF)), label: 'Settings'),
        ],
        onDestinationSelected: (index) {
          if (index == currentIndex) return;
          Widget page = index == 0 ? const HomeScreen() : index == 1 ? const SecurityAnalysisScreen() : const SettingsScreen();
          // FIX: Replaced (_, __, ___) with explicit variable names to resolve the linter warning
          Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => page, transitionDuration: Duration.zero));
        },
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final int weak, fair, strong, total;
  DonutChartPainter({required this.weak, required this.fair, required this.strong, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const double strokeWidth = 25.0;

    if (total == 0) {
      canvas.drawArc(rect, 0, 2 * pi, false, Paint()..color = Colors.grey.shade800..style = PaintingStyle.stroke..strokeWidth = strokeWidth);
      return;
    }

    double startAngle = -pi / 2;
    void drawSegment(int count, Color color) {
      if (count == 0) return;
      final sweepAngle = (count / total) * 2 * pi;
      canvas.drawArc(rect, startAngle, sweepAngle, false, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.butt);
      startAngle += sweepAngle;
    }

    drawSegment(strong, Colors.greenAccent);
    drawSegment(fair, const Color(0xFF00E5FF));
    drawSegment(weak, Colors.redAccent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}