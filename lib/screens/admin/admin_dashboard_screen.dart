import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';
import 'admin_orders_screen.dart';
import 'admin_drivers_screen.dart';
import '../shared/profile_screen.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  static final List<Widget> _screens = [
    const AdminDashboardTab(),
    const AdminOrdersScreen(),
    const AdminDriversScreen(),
    const ProfileScreen(isAdmin: true),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: _screens[state.adminNavIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: state.adminNavIndex,
        onTap: state.setAdminNavIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'Drivers'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = SampleData.stats;
    final orders = context.watch<AppState>().orders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: 'Admin Dashboard',
        actions: [
          IconButton(icon: const Icon(Icons.notifications_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.adminPrimary, Color(0xFF3D566E)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Good ${_greeting()} 👋', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text('Admin Overview', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text("Today's operations at a glance", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Stats Grid
            Text('Statistics', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12, mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                StatsCard(title: 'Total Orders', value: stats.totalOrders.toString(), icon: Icons.receipt_long_rounded, color: AppColors.primary, trend: '+12%'),
                StatsCard(title: 'Active Deliveries', value: stats.activeDeliveries.toString(), icon: Icons.local_shipping_rounded, color: AppColors.accent),
                StatsCard(title: 'Completed Today', value: stats.completedToday.toString(), icon: Icons.check_circle_rounded, color: AppColors.success, trend: '+8%'),
                StatsCard(title: 'Available Drivers', value: stats.availableDrivers.toString(), icon: Icons.people_rounded, color: AppColors.info),
              ],
            ),
            const SizedBox(height: 20),
            // Revenue Card
            _RevenueCard(revenue: stats.totalRevenue),
            const SizedBox(height: 20),
            // Orders by Status
            _OrderStatusChart(orders: orders),
            const SizedBox(height: 20),
            // Recent Orders
            SectionHeader(
              title: 'Recent Orders',
              actionLabel: 'View All',
              onAction: () => context.read<AppState>().setAdminNavIndex(1),
            ),
            const SizedBox(height: 12),
            ...orders.take(3).map((o) => _AdminOrderRow(order: o)),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    return h < 12 ? 'Morning' : h < 17 ? 'Afternoon' : 'Evening';
  }
}

class _RevenueCard extends StatelessWidget {
  final double revenue;
  const _RevenueCard({required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Total Revenue', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('+15.2%', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('TZS ${_formatRevenue(revenue)}', style: const TextStyle(
            fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary,
          )),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3), FlSpot(1, 4.2), FlSpot(2, 3.8),
                      FlSpot(3, 5.1), FlSpot(4, 4.7), FlSpot(5, 6.3), FlSpot(6, 5.8),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRevenue(double r) {
    if (r >= 1000000) return '${(r / 1000000).toStringAsFixed(1)}M';
    if (r >= 1000) return '${(r / 1000).toStringAsFixed(0)}K';
    return r.toStringAsFixed(0);
  }
}

class _OrderStatusChart extends StatelessWidget {
  final List<DeliveryOrder> orders;
  const _OrderStatusChart({required this.orders});

  @override
  Widget build(BuildContext context) {
    final counts = {
      OrderStatus.pending: orders.where((o) => o.status == OrderStatus.pending).length,
      OrderStatus.inTransit: orders.where((o) => o.status == OrderStatus.inTransit).length,
      OrderStatus.delivered: orders.where((o) => o.status == OrderStatus.delivered).length,
      OrderStatus.cancelled: orders.where((o) => o.status == OrderStatus.cancelled).length,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Orders by Status', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 130, height: 130,
                child: PieChart(PieChartData(
                  sections: counts.entries.map((e) {
                    final total = counts.values.fold(0, (a, b) => a + b);
                    final pct = total > 0 ? e.value / total * 100 : 0;
                    return PieChartSectionData(
                      value: e.value.toDouble(),
                      color: e.key.color,
                      radius: 40,
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                  sectionsSpace: 3,
                  centerSpaceRadius: 30,
                )),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: counts.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: e.key.color, borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 8),
                      Text(e.key.label, style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ]),
                  )).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminOrderRow extends StatelessWidget {
  final DeliveryOrder order;
  const _AdminOrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: order.status.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(order.status.icon, color: order.status.color, size: 20),
        ),
        title: Text(order.trackingNumber, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(order.clientName, style: const TextStyle(fontSize: 12)),
        trailing: StatusBadge(status: order.status),
        onTap: () {},
      ),
    );
  }
}
