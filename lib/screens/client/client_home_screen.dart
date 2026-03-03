import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';
import 'client_orders_screen.dart';
import 'place_order_screen.dart';
import 'track_order_screen.dart';
import '../shared/notifications_screen.dart';
import '../shared/profile_screen.dart';

class ClientMainScreen extends StatelessWidget {
  const ClientMainScreen({super.key});

  static final List<Widget> _screens = [
    const ClientHomeTab(),
    const ClientOrdersScreen(),
    const TrackOrderScreen(),
    const ProfileScreen(isAdmin: false),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: _screens[state.clientNavIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          currentIndex: state.clientNavIndex,
          onTap: state.setClientNavIndex,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
            const BottomNavigationBarItem(icon: Icon(Icons.location_searching_rounded), label: 'Track'),
            const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class ClientHomeTab extends StatelessWidget {
  const ClientHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$greeting 👋', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(state.currentUser?.name ?? 'User', style: const TextStyle(
                                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700,
                                  )),
                                ],
                              ),
                            ),
                            Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 24),
                                  ),
                                ),
                                if (state.unreadNotifications > 0)
                                  Positioned(
                                    right: 4, top: 4,
                                    child: Container(
                                      width: 16, height: 16,
                                      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                                      child: Center(child: Text(
                                        state.unreadNotifications.toString(),
                                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Search Bar
                        Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(width: 14),
                              Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
                              SizedBox(width: 8),
                              Text('Search orders, tracking...', style: TextStyle(color: AppColors.textHint, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  // Promo Banner
                  _buildPromoBanner(),
                  const SizedBox(height: 24),
                  // Recent Orders
                  SectionHeader(
                    title: 'Recent Orders',
                    actionLabel: 'View All',
                    onAction: () => state.setClientNavIndex(1),
                  ),
                  const SizedBox(height: 12),
                  ...state.orders.take(3).map((o) => OrderCard(
                    order: o,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => OrderDetailScreen(order: o))),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaceOrderScreen())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Order'),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.send_rounded, 'label': 'Send', 'color': AppColors.primary, 'screen': 'place'},
      {'icon': Icons.location_searching_rounded, 'label': 'Track', 'color': AppColors.info, 'screen': 'track'},
      {'icon': Icons.history_rounded, 'label': 'History', 'color': AppColors.success, 'screen': 'orders'},
      {'icon': Icons.support_agent_rounded, 'label': 'Support', 'color': AppColors.warning, 'screen': 'support'},
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: actions.map((a) {
        final color = a['color'] as Color;
        return GestureDetector(
          onTap: () {
            if (a['screen'] == 'place') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaceOrderScreen()));
            } else if (a['screen'] == 'track') {
              context.read<AppState>().setClientNavIndex(2);
            } else if (a['screen'] == 'orders') {
              context.read<AppState>().setClientNavIndex(1);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(a['icon'] as IconData, color: color, size: 26),
              ),
              const SizedBox(height: 6),
              Text(a['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎉 Special Offer!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Get 20% off on Express Delivery today!', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Order Now', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_shipping_rounded, size: 70, color: Colors.white24),
        ],
      ),
    );
  }
}

// ─── Order Detail Screen ───────────────────────────────────────
class OrderDetailScreen extends StatelessWidget {
  final DeliveryOrder order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: order.trackingNumber, showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [order.status.color, order.status.color.withOpacity(0.7)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(order.status.icon, color: Colors.white, size: 36),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(order.status.label, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Updated just now', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Details
            _DetailCard(title: 'Package Info', items: [
              _DetailItem('Description', order.packageDescription),
              _DetailItem('Weight', '${order.packageWeight} kg'),
              _DetailItem('Type', order.deliveryType),
              _DetailItem('Payment', order.paymentMethod),
              _DetailItem('Amount', 'TZS ${order.amount.toStringAsFixed(0)}'),
            ]),
            const SizedBox(height: 16),
            _DetailCard(title: 'Addresses', items: [
              _DetailItem('Pickup', order.pickupAddress),
              _DetailItem('Delivery', order.deliveryAddress),
            ]),
            if (order.driverName != null) ...[
              const SizedBox(height: 16),
              _DetailCard(title: 'Driver', items: [
                _DetailItem('Name', order.driverName!),
                _DetailItem('Phone', order.driverPhone ?? ''),
              ]),
            ],
            const SizedBox(height: 16),
            // Timeline
            if (order.timeline.isNotEmpty) _TimelineCard(timeline: order.timeline),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<_DetailItem> items;
  const _DetailCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 90, child: Text(item.label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  const _DetailItem(this.label, this.value);
}

class _TimelineCard extends StatelessWidget {
  final List<OrderTimeline> timeline;
  const _TimelineCard({required this.timeline});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery Timeline', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...timeline.asMap().entries.map((entry) {
              final item = entry.value;
              final isLast = entry.key == timeline.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(children: [
                    Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.isCompleted ? AppColors.success : item.isCurrent ? AppColors.accent : AppColors.border,
                      ),
                      child: item.isCompleted ? const Icon(Icons.check, color: Colors.white, size: 10) : null,
                    ),
                    if (!isLast) Container(width: 2, height: 40, color: item.isCompleted ? AppColors.success : AppColors.border),
                  ]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.title, style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14,
                          color: item.isCurrent ? AppColors.accent : null,
                        )),
                        const SizedBox(height: 2),
                        Text(item.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ]),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
