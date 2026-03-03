import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';
import '../client/client_home_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  OrderStatus? _filterStatus;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final allOrders = context.watch<AppState>().orders;
    final filtered = allOrders.where((o) {
      final matchesStatus = _filterStatus == null || o.status == _filterStatus;
      final matchesSearch = _search.isEmpty ||
          o.trackingNumber.toLowerCase().contains(_search.toLowerCase()) ||
          o.clientName.toLowerCase().contains(_search.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Manage Orders',
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Search + Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() { _search = v; }),
                  decoration: InputDecoration(
                    hintText: 'Search orders, clients...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [null, ...OrderStatus.values].map((status) {
                      final isSelected = _filterStatus == status;
                      return GestureDetector(
                        onTap: () => setState(() { _filterStatus = status; }),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? (status?.color ?? AppColors.primary) : AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? Colors.transparent : AppColors.border),
                          ),
                          child: Text(
                            status?.label ?? 'All',
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(children: [
              Text('${filtered.length} orders', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ]),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(icon: Icons.receipt_long_rounded, title: 'No orders', subtitle: 'No orders match your filter')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _AdminOrderCard(order: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final DeliveryOrder order;
  const _AdminOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showOrderActions(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusBadge(status: order.status),
                  const Spacer(),
                  Text(order.trackingNumber, style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary,
                  )),
                ],
              ),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.person_rounded, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(order.clientName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                const Icon(Icons.payments_rounded, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('TZS ${order.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.location_on_rounded, size: 14, color: AppColors.error),
                const SizedBox(width: 4),
                Expanded(child: Text(order.deliveryAddress, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              if (order.driverName != null) ...[
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.two_wheeler_rounded, size: 14, color: AppColors.info),
                  const SizedBox(width: 4),
                  Text(order.driverName!, style: const TextStyle(fontSize: 12, color: AppColors.info, fontWeight: FontWeight.w500)),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderActions(BuildContext context) {
    final state = context.read<AppState>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(order.trackingNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 16),
            const Divider(),
            ...OrderStatus.values.map((s) => ListTile(
              leading: CircleAvatar(backgroundColor: s.color.withOpacity(0.15), child: Icon(s.icon, color: s.color, size: 18)),
              title: Text('Mark as ${s.label}'),
              onTap: () {
                state.updateOrderStatus(order.id, s);
                Navigator.pop(context);
              },
              selected: order.status == s,
              selectedTileColor: s.color.withOpacity(0.05),
            )),
          ],
        ),
      ),
    );
  }
}
