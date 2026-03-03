import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.local_shipping_rounded, size: 56, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text('DeliverEasy', style: TextStyle(
                  fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5,
                )),
                const SizedBox(height: 8),
                Text('Fast. Reliable. Affordable.', style: TextStyle(
                  fontSize: 16, color: Colors.white.withOpacity(0.7), letterSpacing: 0.3,
                )),
                const SizedBox(height: 60),
                const Text('Choose your role', style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white,
                )),
                const SizedBox(height: 8),
                Text('How would you like to continue?', style: TextStyle(
                  fontSize: 14, color: Colors.white.withOpacity(0.6),
                )),
                const SizedBox(height: 40),
                // Role Cards
                _RoleCard(
                  icon: Icons.person_rounded,
                  title: 'Client',
                  subtitle: 'Send & track packages',
                  gradient: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
                  onTap: () {
                    context.read<AppState>().loginAsClient();
                    Navigator.pushReplacementNamed(context, '/client');
                  },
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Admin',
                  subtitle: 'Manage operations & drivers',
                  gradient: [const Color(0xFFFF6B35), const Color(0xFFD44E1A)],
                  onTap: () {
                    context.read<AppState>().loginAsAdmin();
                    Navigator.pushReplacementNamed(context, '/admin');
                  },
                ),
                const Spacer(),
                // Language selector
                _LanguageSelector(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon, required this.title, required this.subtitle,
    required this.gradient, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: gradient.last.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LangBtn(
          label: 'EN',
          subtitle: 'English',
          isSelected: state.locale.languageCode == 'en',
          onTap: () => state.setLocale(const Locale('en')),
        ),
        const SizedBox(width: 12),
        _LangBtn(
          label: 'SW',
          subtitle: 'Kiswahili',
          isSelected: state.locale.languageCode == 'sw',
          onTap: () => state.setLocale(const Locale('sw')),
        ),
      ],
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangBtn({required this.label, required this.subtitle, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.white : Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14,
              color: isSelected ? AppColors.primary : Colors.white,
            )),
            Text(subtitle, style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppColors.textSecondary : Colors.white.withOpacity(0.7),
            )),
          ],
        ),
      ),
    );
  }
}
