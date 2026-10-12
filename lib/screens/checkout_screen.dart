import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/delivery_date_sheet.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _recipientNameController = TextEditingController(text: 'Sophia Montgomery');
  final TextEditingController _recipientPhoneController = TextEditingController(text: '+1 (555) 438-9921');
  final TextEditingController _addressController = TextEditingController(text: '450 Lexington Ave, Suite 12B, New York, NY 10017');
  final TextEditingController _instructionsController = TextEditingController(text: 'Leave at front desk concierge if recipient is in a meeting.');
  final TextEditingController _senderNameController = TextEditingController(text: 'Julian Sterling');

  bool _isAnonymous = false;
  String _selectedPaymentMethod = 'Apple Pay';

  final List<Map<String, dynamic>> _paymentOptions = [
    {'name': 'Apple Pay', 'icon': Icons.apple, 'sub': 'One-touch secure payment'},
    {'name': 'Credit or Debit Card', 'icon': Icons.credit_card, 'sub': 'Visa, Mastercard, Amex (•••• 4242)'},
    {'name': 'Instant Bank QR Transfer', 'icon': Icons.qr_code_2_rounded, 'sub': 'Zero fees with instant receipt confirmation'},
    {'name': 'Cash on Delivery', 'icon': Icons.payments_outlined, 'sub': 'Pay when blooms arrive at the door'},
  ];

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _addressController.dispose();
    _instructionsController.dispose();
    _senderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipient & Delivery'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Recipient Information
                    Text(
                      '1. Recipient Details',
                      style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Who should our chilled delivery courier ask for?',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _recipientNameController,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter recipient name' : null,
                      decoration: const InputDecoration(
                        labelText: 'Recipient Full Name *',
                        prefixIcon: Icon(Icons.person, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _recipientPhoneController,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter recipient phone number' : null,
                      decoration: const InputDecoration(
                        labelText: 'Recipient Phone Number *',
                        prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Please enter delivery address' : null,
                      decoration: const InputDecoration(
                        labelText: 'Complete Delivery Address *',
                        prefixIcon: Icon(Icons.location_on, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _instructionsController,
                      decoration: const InputDecoration(
                        labelText: 'Driver Instructions (Optional)',
                        hintText: 'e.g. Ring bell, leave with doorman, unit code',
                        prefixIcon: Icon(Icons.info_outline, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Gifting & Sender Details
                    Text(
                      '2. Gifting Privacy',
                      style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            SwitchListTile(
                              value: _isAnonymous,
                              onChanged: (v) => setState(() => _isAnonymous = v),
                              activeTrackColor: AppColors.primary,
                              title: const Text('Send as Secret Admirer / Anonymous', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              subtitle: const Text('Your name will not appear on delivery invoices or packing slips', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              contentPadding: EdgeInsets.zero,
                            ),
                            if (!_isAnonymous) ...[
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _senderNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Your Name (Sender)',
                                  prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 3: Delivery Schedule Confirmation
                    Text(
                      '3. Delivery Slot Confirmation',
                      style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, color: AppColors.primary, size: 24),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateFormat.format(cart.selectedDeliveryDate),
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  cart.selectedDeliverySlot,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              DeliveryDateSheet.show(
                                context: context,
                                initialDate: cart.selectedDeliveryDate,
                                initialSlot: cart.selectedDeliverySlot,
                                onSelected: (date, slot) {
                                  cart.setDeliveryDate(date);
                                  cart.setDeliverySlot(slot);
                                },
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Text('Change', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 4: Payment Method Selector
                    Text(
                      '4. Payment Method',
                      style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: _paymentOptions.map((opt) {
                        final isSelected = _selectedPaymentMethod == opt['name'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPaymentMethod = opt['name']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.08) : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: isSelected ? 1.8 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                  color: isSelected ? AppColors.primary : AppColors.textLight,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(opt['icon'] as IconData, size: 20, color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(opt['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                      Text(opt['sub'], style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Bottom Place Order Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
                border: const Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Total to Pay', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        Text(
                          '\$${cart.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Create order
                          final createdOrder = orderProvider.createOrder(
                            items: cart.items,
                            subtotal: cart.subtotal,
                            deliveryFee: cart.deliveryFee,
                            discount: cart.discountAmount,
                            total: cart.total,
                            deliveryDate: cart.selectedDeliveryDate,
                            deliveryTimeSlot: cart.selectedDeliverySlot,
                            recipientName: _recipientNameController.text.trim(),
                            recipientPhone: _recipientPhoneController.text.trim(),
                            deliveryAddress: _addressController.text.trim(),
                            deliveryInstructions: _instructionsController.text.trim(),
                            senderName: _isAnonymous ? 'Secret Admirer' : _senderNameController.text.trim(),
                            isAnonymous: _isAnonymous,
                            paymentMethod: _selectedPaymentMethod,
                          );

                          // Clear cart
                          cart.clearCart();

                          // Navigate to success
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderSuccessScreen(order: createdOrder),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_outline, size: 16),
                          SizedBox(width: 8),
                          Text('Place & Pay Order'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
