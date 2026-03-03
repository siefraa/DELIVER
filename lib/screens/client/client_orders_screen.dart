import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';
import 'client_home_screen.dart';

// ─── Client Orders Screen ──────────────────────────────────────
class ClientOrdersScreen extends StatefulWidget {
  const ClientOrdersScreen({super.key});

  @override
  State<ClientOrdersScreen> createState() => _ClientOrdersScreenState();
}

class _ClientOrdersScreenState extends State<ClientOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['All', 'Active', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AppState>().orders;
    return Scaffold(
      appBar: GradientAppBar(
        title: 'My Orders',
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tabController,
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
              indicatorColor: AppColors.accent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OrderList(orders: orders),
                _OrderList(orders: orders.where((o) => o.status == OrderStatus.inTransit || o.status == OrderStatus.pickup || o.status == OrderStatus.pending).toList()),
                _OrderList(orders: orders.where((o) => o.status == OrderStatus.delivered).toList()),
                _OrderList(orders: orders.where((o) => o.status == OrderStatus.cancelled).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<DeliveryOrder> orders;
  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'No orders yet',
        subtitle: 'Your orders will appear here',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, i) => OrderCard(
        order: orders[i],
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: orders[i]))),
      ),
    );
  }
}

// ─── Track Order Screen ────────────────────────────────────────
class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final _controller = TextEditingController();
  DeliveryOrder? _foundOrder;
  bool _searched = false;

  void _search() {
    final query = _controller.text.trim().toUpperCase();
    final orders = context.read<AppState>().orders;
    final found = orders.where((o) => o.trackingNumber.toUpperCase().contains(query)).firstOrNull;
    setState(() {
      _foundOrder = found;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Track Package'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Track Your Package', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Enter tracking number below', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'e.g. DEL-2024-001',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.7)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _search,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Track'),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_searched && _foundOrder == null)
              const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Order not found',
                subtitle: 'Check your tracking number and try again',
              )
            else if (_foundOrder != null) ...[
              Text('Tracking Result', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              OrderCard(order: _foundOrder!),
              const SizedBox(height: 16),
              // Live status steps
              _TrackingProgress(order: _foundOrder!),
            ] else ...[
              _buildRecentTracks(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTracks() {
    final orders = context.watch<AppState>().orders;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Orders', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...orders.take(2).map((o) => OrderCard(
          order: o,
          onTap: () => setState(() { _foundOrder = o; _searched = true; }),
        )),
      ],
    );
  }
}

class _TrackingProgress extends StatelessWidget {
  final DeliveryOrder order;
  const _TrackingProgress({required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'status': OrderStatus.pending, 'label': 'Order Placed', 'icon': Icons.receipt_long_rounded},
      {'status': OrderStatus.pickup, 'label': 'Picked Up', 'icon': Icons.inventory_2_rounded},
      {'status': OrderStatus.inTransit, 'label': 'In Transit', 'icon': Icons.local_shipping_rounded},
      {'status': OrderStatus.delivered, 'label': 'Delivered', 'icon': Icons.check_circle_rounded},
    ];

    final statusIndex = {
      OrderStatus.pending: 0,
      OrderStatus.pickup: 1,
      OrderStatus.inTransit: 2,
      OrderStatus.delivered: 3,
      OrderStatus.cancelled: -1,
    }[order.status] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery Progress', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              children: steps.asMap().entries.map((entry) {
                final idx = entry.key;
                final step = entry.value;
                final isCompleted = idx <= statusIndex;
                final isCurrent = idx == statusIndex;
                return Expanded(
                  child: Row(children: [
                    Expanded(
                      child: Column(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? (isCurrent ? AppColors.accent : AppColors.success) : AppColors.background,
                            border: Border.all(
                              color: isCompleted ? (isCurrent ? AppColors.accent : AppColors.success) : AppColors.border,
                              width: isCurrent ? 3 : 2,
                            ),
                          ),
                          child: Icon(
                            step['icon'] as IconData,
                            size: 20,
                            color: isCompleted ? Colors.white : AppColors.textHint,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(step['label'] as String, style: TextStyle(
                          fontSize: 10, fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal,
                          color: isCurrent ? AppColors.accent : (isCompleted ? AppColors.success : AppColors.textHint),
                        ), textAlign: TextAlign.center),
                      ]),
                    ),
                    if (idx < steps.length - 1)
                      Container(height: 2, width: 20, color: idx < statusIndex ? AppColors.success : AppColors.border,
                          margin: const EdgeInsets.only(bottom: 20)),
                  ]),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
