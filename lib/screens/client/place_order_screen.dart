import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/app_state.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/shared_widgets.dart';

class PlaceOrderScreen extends StatefulWidget {
  const PlaceOrderScreen({super.key});

  @override
  State<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  final _pickupController = TextEditingController(text: 'Kariakoo Market, Dar es Salaam');
  final _deliveryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController(text: '1.0');
  final _instructionsController = TextEditingController();

  String _deliveryType = 'Standard';
  String _paymentMethod = 'Mobile Money';
  double _estimatedPrice = 0;

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_calculatePrice);
  }

  void _calculatePrice() {
    final w = double.tryParse(_weightController.text) ?? 1.0;
    setState(() {
      _estimatedPrice = _deliveryType == 'Express' ? (w * 5000 + 8000) : (w * 3000 + 5000);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: 'Place Order', showBack: true),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: Form(
                key: _formKey,
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                    _buildConfirmationStep(),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Addresses', 'Package', 'Payment', 'Confirm'];
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final isActive = e.key == _currentStep;
          final isDone = e.key < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? AppColors.success : isActive ? AppColors.accent : Colors.white.withOpacity(0.3),
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : Text('${e.key + 1}', style: TextStyle(
                                color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.bold, fontSize: 13,
                              )),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(e.value, style: TextStyle(
                      color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                      fontSize: 10, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    )),
                  ]),
                ),
                if (e.key < steps.length - 1)
                  Container(height: 2, width: 20, color: Colors.white.withOpacity(0.3), margin: const EdgeInsets.only(bottom: 22)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where to & from?', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          const Text('Enter pickup and delivery addresses', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                AppTextField(
                  label: 'Pickup Address',
                  prefixIcon: Icons.radio_button_checked,
                  controller: _pickupController,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Row(children: [
                    Icon(Icons.more_vert, color: AppColors.border, size: 20),
                  ]),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  label: 'Delivery Address',
                  prefixIcon: Icons.location_on_rounded,
                  controller: _deliveryController,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          _buildDeliveryTypeSelector(),
        ],
      ),
    );
  }

  Widget _buildDeliveryTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery Type', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: ['Standard', 'Express', 'Same Day'].map((type) {
            final isSelected = _deliveryType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() { _deliveryType = type; });
                  _calculatePrice();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        type == 'Standard' ? Icons.local_shipping_rounded : type == 'Express' ? Icons.flash_on_rounded : Icons.today_rounded,
                        color: isSelected ? Colors.white : AppColors.textSecondary, size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(type, style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      )),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Package Details', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          const Text('Tell us about your package', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                AppTextField(
                  label: 'Package Description',
                  prefixIcon: Icons.inventory_2_rounded,
                  controller: _descriptionController,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Weight (kg)',
                  prefixIcon: Icons.fitness_center_rounded,
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Special Instructions (Optional)',
                  hint: 'Fragile, keep upright...',
                  prefixIcon: Icons.note_rounded,
                  controller: _instructionsController,
                  maxLines: 3,
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          // Price preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calculate_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Estimated Price', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  Text('TZS ${_estimatedPrice.toStringAsFixed(0)}', style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary,
                  )),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Method', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          const Text('Choose how you would like to pay', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ...['Cash on Delivery', 'Mobile Money', 'Credit Card'].map((method) {
            final icons = {'Cash on Delivery': Icons.money_rounded, 'Mobile Money': Icons.phone_android_rounded, 'Credit Card': Icons.credit_card_rounded};
            final isSelected = _paymentMethod == method;
            return GestureDetector(
              onTap: () => setState(() { _paymentMethod = method; }),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icons[method]!, color: isSelected ? Colors.white : AppColors.textSecondary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Text(method, style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    )),
                    const Spacer(),
                    if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          const Text('Review your order before placing it', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _SummaryRow('From', _pickupController.text.isEmpty ? '—' : _pickupController.text),
                const Divider(),
                _SummaryRow('To', _deliveryController.text.isEmpty ? '—' : _deliveryController.text),
                const Divider(),
                _SummaryRow('Package', _descriptionController.text.isEmpty ? '—' : _descriptionController.text),
                const Divider(),
                _SummaryRow('Type', _deliveryType),
                const Divider(),
                _SummaryRow('Payment', _paymentMethod),
                const Divider(),
                _SummaryRow('Total', 'TZS ${_estimatedPrice.toStringAsFixed(0)}', isTotal: true),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _placeOrder,
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Confirm & Place Order'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    if (_currentStep == 3) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() { _currentStep--; }),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _nextStep,
              child: Text(_currentStep == 2 ? 'Review Order' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() { _currentStep++; });
      _calculatePrice();
    }
  }

  Future<void> _placeOrder() async {
    setState(() { _isLoading = true; });
    await Future.delayed(const Duration(seconds: 2));
    final newOrder = DeliveryOrder(
      id: const Uuid().v4(),
      trackingNumber: 'DEL-2024-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      clientName: context.read<AppState>().currentUser?.name ?? 'Client',
      clientPhone: context.read<AppState>().currentUser?.phone ?? '',
      pickupAddress: _pickupController.text,
      deliveryAddress: _deliveryController.text,
      packageDescription: _descriptionController.text,
      packageWeight: double.tryParse(_weightController.text) ?? 1.0,
      amount: _estimatedPrice,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      estimatedDelivery: DateTime.now().add(const Duration(hours: 5)),
      deliveryType: _deliveryType,
      paymentMethod: _paymentMethod,
      timeline: [],
    );
    context.read<AppState>().addOrder(newOrder);
    setState(() { _isLoading = false; });
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Order Placed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Tracking: ${newOrder.trackingNumber}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 4),
            const Text('Your package will be picked up soon!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
          ]),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Track Order'),
            ),
          ],
        ),
      );
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  const _SummaryRow(this.label, this.value, {this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: TextStyle(
            color: AppColors.textSecondary, fontSize: isTotal ? 15 : 13, fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
          )),
          const Spacer(),
          Text(value, style: TextStyle(
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? AppColors.accent : AppColors.textPrimary,
          )),
        ],
      ),
    );
  }
}
