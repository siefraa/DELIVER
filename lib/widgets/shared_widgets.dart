import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ─── Gradient App Bar ──────────────────────────────────────────
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const GradientAppBar({
    super.key, required this.title,
    this.actions, this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: showBack,
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ─── Status Badge ──────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 4),
          Text(status.label, style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: status.color,
          )),
        ],
      ),
    );
  }
}

// ─── Order Card ────────────────────────────────────────────────
class OrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final VoidCallback? onTap;
  final bool showActions;

  const OrderCard({super.key, required this.order, this.onTap, this.showActions = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.trackingNumber, style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary,
                        )),
                        const SizedBox(height: 2),
                        Text(order.packageDescription, style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary,
                        )),
                      ],
                    ),
                  ),
                  StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildAddressRow(Icons.radio_button_checked, AppColors.success, order.pickupAddress),
              const SizedBox(height: 6),
              _buildDottedLine(),
              const SizedBox(height: 6),
              _buildAddressRow(Icons.location_on_rounded, AppColors.error, order.deliveryAddress),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(Icons.person_rounded, order.clientName),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.payments_rounded, 'TZS ${_formatPrice(order.amount)}'),
                  const Spacer(),
                  Text(_formatTime(order.createdAt), style: const TextStyle(
                    fontSize: 11, color: AppColors.textHint,
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, Color color, String address) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(address, style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildDottedLine() {
    return Row(children: [
      const SizedBox(width: 7),
      Container(width: 2, height: 16, color: AppColors.border),
    ]);
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}K';
    return price.toStringAsFixed(0);
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─── Driver Card ───────────────────────────────────────────────
class DriverCard extends StatelessWidget {
  final Driver driver;
  final VoidCallback? onTap;
  final bool showAssign;

  const DriverCard({super.key, required this.driver, this.onTap, this.showAssign = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                driver.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            Positioned(
              right: 0, bottom: 0,
              child: Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  color: driver.statusColor, shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(driver.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.two_wheeler_rounded, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(driver.vehicleType, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 12),
              const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF39C12)),
              const SizedBox(width: 2),
              Text(driver.rating.toString(), style: const TextStyle(fontSize: 12)),
            ]),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: driver.statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(driver.statusLabel, style: TextStyle(
                fontSize: 10, color: driver.statusColor, fontWeight: FontWeight.w600,
              )),
            ),
          ],
        ),
        trailing: showAssign
            ? ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 32),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: const Text('Assign'),
              )
            : IconButton(icon: const Icon(Icons.more_vert), onPressed: onTap),
      ),
    );
  }
}

// ─── Stats Card ────────────────────────────────────────────────
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;

  const StatsCard({
    super.key, required this.title, required this.value,
    required this.icon, required this.color, this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(trend!, style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!, style: const TextStyle(fontSize: 13)),
          ),
      ],
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButton;

  const EmptyState({
    super.key, required this.icon, required this.title,
    required this.subtitle, this.buttonLabel, this.onButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: AppColors.primary.withOpacity(0.5)),
            ),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
            if (buttonLabel != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: ElevatedButton(onPressed: onButton, child: Text(buttonLabel!)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Custom Text Field ─────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final Widget? suffix;

  const AppTextField({
    super.key, required this.label, this.hint, this.prefixIcon,
    this.obscureText = false, this.controller, this.validator,
    this.keyboardType, this.maxLines = 1, this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        suffixIcon: suffix,
      ),
    );
  }
}

// ─── Loading Overlay ───────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black45,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          ),
      ],
    );
  }
}
