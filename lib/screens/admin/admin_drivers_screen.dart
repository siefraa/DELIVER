import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';

class AdminDriversScreen extends StatefulWidget {
  const AdminDriversScreen({super.key});

  @override
  State<AdminDriversScreen> createState() => _AdminDriversScreenState();
}

class _AdminDriversScreenState extends State<AdminDriversScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final drivers = context.watch<AppState>().drivers;
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Manage Drivers',
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => _showAddDriver(context)),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'All'), Tab(text: 'Available'), Tab(text: 'Busy')],
              indicatorColor: AppColors.accent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _DriverList(drivers: drivers),
                _DriverList(drivers: drivers.where((d) => d.status == DriverStatus.available).toList()),
                _DriverList(drivers: drivers.where((d) => d.status == DriverStatus.busy).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDriver(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => const _AddDriverSheet(),
    );
  }
}

class _DriverList extends StatelessWidget {
  final List<Driver> drivers;
  const _DriverList({required this.drivers});

  @override
  Widget build(BuildContext context) {
    if (drivers.isEmpty) {
      return const EmptyState(icon: Icons.people_rounded, title: 'No drivers', subtitle: 'No drivers in this category');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: drivers.length,
      itemBuilder: (_, i) => _DriverDetailCard(driver: drivers[i]),
    );
  }
}

class _DriverDetailCard extends StatelessWidget {
  final Driver driver;
  const _DriverDetailCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: Text(
                        driver.name[0],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          color: driver.statusColor, shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(driver.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(driver.phone, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: driver.statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(driver.statusLabel, style: TextStyle(
                          fontSize: 10, color: driver.statusColor, fontWeight: FontWeight.w600,
                        )),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                        child: Text(driver.vehicleType, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ),
                    ]),
                  ]),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'call', child: Text('Call')),
                    const PopupMenuItem(value: 'delete', child: Text('Remove', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                _StatItem(Icons.local_shipping_rounded, 'Deliveries', driver.totalDeliveries.toString()),
                const SizedBox(width: 16),
                _StatItem(Icons.star_rounded, 'Rating', driver.rating.toStringAsFixed(1), color: const Color(0xFFF39C12)),
                const SizedBox(width: 16),
                _StatItem(Icons.badge_rounded, 'License', driver.licenseNumber),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  const _StatItem(this.icon, this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(children: [
        Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ]),
    );
  }
}

class _AddDriverSheet extends StatelessWidget {
  const _AddDriverSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Add New Driver', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            const AppTextField(label: 'Full Name', prefixIcon: Icons.person_rounded),
            const SizedBox(height: 12),
            const AppTextField(label: 'Phone Number', prefixIcon: Icons.phone_rounded, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            const AppTextField(label: 'Email', prefixIcon: Icons.email_rounded, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            const AppTextField(label: 'License Number', prefixIcon: Icons.badge_rounded),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: 'Motorcycle',
              decoration: InputDecoration(
                labelText: 'Vehicle Type',
                prefixIcon: const Icon(Icons.two_wheeler_rounded, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ['Motorcycle', 'Bicycle', 'Car', 'Van', 'Truck']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (_) {},
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Add Driver'),
            ),
          ],
        ),
      ),
    );
  }
}
