import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

// ─── Profile Screen ────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  final bool isAdmin;
  const ProfileScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isAdmin
                        ? [AppColors.adminPrimary, const Color(0xFF3D566E)]
                        : [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          (user?.name ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(user?.name ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text('Profile'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Stats
                  Row(
                    children: [
                      _ProfileStat('Orders', user?.totalOrders.toString() ?? '0', Icons.receipt_long_rounded),
                      const SizedBox(width: 12),
                      _ProfileStat('Rating', '4.8', Icons.star_rounded, color: const Color(0xFFF39C12)),
                      const SizedBox(width: 12),
                      _ProfileStat('Since', '2023', Icons.calendar_today_rounded),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Settings sections
                  _SettingsSection(title: 'Account', items: [
                    _SettingsTile(Icons.person_outline_rounded, 'Edit Profile', onTap: () {}),
                    _SettingsTile(Icons.lock_outline_rounded, 'Change Password', onTap: () {}),
                    _SettingsTile(Icons.notifications_outlined, 'Notifications', trailing: Switch(
                      value: true, onChanged: (_) {}, activeColor: AppColors.accent,
                    )),
                  ]),
                  const SizedBox(height: 12),
                  _SettingsSection(title: 'Preferences', items: [
                    _SettingsTile(Icons.language_rounded, 'Language',
                        trailing: _LanguagePicker(), onTap: null),
                    _SettingsTile(Icons.dark_mode_rounded, 'Dark Mode',
                        trailing: Switch(
                          value: state.isDarkMode,
                          onChanged: (_) => state.toggleDarkMode(),
                          activeColor: AppColors.accent,
                        )),
                  ]),
                  const SizedBox(height: 12),
                  _SettingsSection(title: 'Support', items: [
                    _SettingsTile(Icons.help_outline_rounded, 'Help & Support', onTap: () {}),
                    _SettingsTile(Icons.privacy_tip_outlined, 'Privacy Policy', onTap: () {}),
                    _SettingsTile(Icons.description_outlined, 'Terms of Service', onTap: () {}),
                    _SettingsTile(Icons.info_outline_rounded, 'About', trailing: const Text('v1.0.0', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                  ]),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context, state),
                    icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                    label: const Text('Logout', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      foregroundColor: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              state.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  const _ProfileStat(this.label, this.value, this.icon, {this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
        child: Column(children: [
          Icon(icon, color: color ?? AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textSecondary)),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(children: items.asMap().entries.map((e) {
            return Column(children: [
              e.value,
              if (e.key < items.length - 1) const Divider(height: 1, indent: 50),
            ]);
          }).toList()),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile(this.icon, this.title, {this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textHint) : null),
      onTap: onTap,
      dense: true,
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return DropdownButton<String>(
      value: state.locale.languageCode,
      underline: const SizedBox(),
      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Poppins'),
      onChanged: (v) => state.setLocale(Locale(v!)),
      items: const [
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'sw', child: Text('Kiswahili')),
      ],
    );
  }
}

// ─── Notifications Screen ──────────────────────────────────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static final List<Map<String, dynamic>> _notifications = [
    {'title': 'Order Picked Up!', 'message': 'DEL-2024-001 has been picked up by John Mwangi', 'time': '5 min ago', 'icon': Icons.inventory_2_rounded, 'color': AppColors.info, 'read': false},
    {'title': 'Delivery Successful', 'message': 'DEL-2024-002 has been delivered successfully!', 'time': '2 hrs ago', 'icon': Icons.check_circle_rounded, 'color': AppColors.success, 'read': false},
    {'title': 'New Promo Available', 'message': 'Get 20% off on Express delivery today!', 'time': '1 day ago', 'icon': Icons.local_offer_rounded, 'color': AppColors.accent, 'read': false},
    {'title': 'Driver Assigned', 'message': 'Sarah Odhiambo assigned to your order DEL-2024-004', 'time': '2 days ago', 'icon': Icons.person_rounded, 'color': AppColors.primary, 'read': true},
    {'title': 'Payment Received', 'message': 'Payment of TZS 15,000 received for DEL-2024-001', 'time': '3 days ago', 'icon': Icons.payments_rounded, 'color': AppColors.success, 'read': true},
  ];

  @override
  Widget build(BuildContext context) {
    context.read<AppState>().markNotificationsRead();
    return Scaffold(
      appBar: const GradientAppBar(title: 'Notifications', showBack: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, i) {
          final n = _notifications[i];
          return Card(
            color: n['read'] ? null : AppColors.primary.withOpacity(0.04),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (n['color'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 22),
              ),
              title: Text(n['title'], style: TextStyle(fontWeight: n['read'] ? FontWeight.w500 : FontWeight.w700, fontSize: 14)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 2),
                Text(n['message'], style: const TextStyle(fontSize: 12), maxLines: 2),
                const SizedBox(height: 4),
                Text(n['time'], style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ]),
              trailing: !n['read'] ? Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
              ) : null,
            ),
          );
        },
      ),
    );
  }
}
