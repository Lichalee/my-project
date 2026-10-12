import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';
import '../models/gift_addon.dart';
import '../theme/app_colors.dart';
import '../data/mock_data.dart';
import '../widgets/delivery_date_sheet.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onExploreMore;

  const CartScreen({super.key, this.onExploreMore});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  String? _couponError;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final dateFormat = DateFormat('EEE, MMM d');

    if (cart.items.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                Text(
                  'Your Flower Bag is Empty',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fresh hand-tied blooms and curated bespoke gifts are waiting for you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => widget.onExploreMore?.call(),
                  icon: const Icon(Icons.local_florist, size: 18),
                  label: const Text('Explore Fresh Blooms'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Sub-header with Title and Clear Bag action
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Flower Bag (${cart.itemCount})',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  tooltip: 'Clear Bag',
                  icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.textSecondary),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear Bag?'),
                        content: const Text('Are you sure you want to remove all items from your bag?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              cart.clearCart();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Slot Quick Selector Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery: ${dateFormat.format(cart.selectedDeliveryDate)}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              Text(
                                cart.selectedDeliverySlot,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
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
                          child: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cart Items List
                  Text(
                    'Order Items',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.imageUrl,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 72,
                                      height: 72,
                                      color: AppColors.surfaceVariant,
                                      child: const Icon(Icons.local_florist, color: AppColors.primary),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subtitle,
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '\$${item.unitPrice.toStringAsFixed(0)} each',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: AppColors.textLight),
                                  onPressed: () => cart.removeItem(item.id),
                                ),
                              ],
                            ),

                            // Greeting message tag if present
                            if (item.greetingMessage != null && item.greetingMessage!.trim().isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGoldLight.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Text('💌 ', style: TextStyle(fontSize: 12)),
                                    Expanded(
                                      child: Text(
                                        'Note: "${item.greetingMessage}"',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFF634A0A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 8),

                            // Stepper & Row Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () => cart.updateQuantity(item.id, item.quantity - 1),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          child: Icon(Icons.remove, size: 14),
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                      InkWell(
                                        onTap: () => cart.updateQuantity(item.id, item.quantity + 1),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          child: Icon(Icons.add, size: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${item.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Upsell Addon Treats Suggestions
                  Text(
                    'Perfect Companions (Add to Order)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: MockData.giftAddons.length,
                      itemBuilder: (context, index) {
                        final addon = MockData.giftAddons[index];
                        return _AddonSuggestionCard(addon: addon);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Promo Coupon Code Input
                  Text(
                    'Promotion Coupon',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  if (cart.appliedCoupon != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.discount_outlined, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            '${cart.appliedCoupon} ( ${(cart.discountPercentage * 100).toInt()}% OFF )',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: AppColors.primary),
                            onPressed: () => cart.removeCoupon(),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'Enter code (e.g. BLOOM10, SPRING20)',
                              errorText: _couponError,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (_couponController.text.trim().isEmpty) return;
                            final success = cart.applyCoupon(_couponController.text);
                            if (success) {
                              setState(() {
                                _couponError = null;
                                _couponController.clear();
                              });
                            } else {
                              setState(() {
                                _couponError = 'Invalid code. Try BLOOM10 or SPRING20';
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          ),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Order Cost Summary Box
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(title: 'Subtotal', value: '\$${cart.subtotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        if (cart.discountAmount > 0) ...[
                          _SummaryRow(
                            title: 'Discount (${(cart.discountPercentage * 100).toInt()}%)',
                            value: '-\$${cart.discountAmount.toStringAsFixed(2)}',
                            isDiscount: true,
                          ),
                          const SizedBox(height: 8),
                        ],
                        _SummaryRow(
                          title: 'Chilled Courier Delivery',
                          value: cart.deliveryFee == 0 ? 'FREE' : '\$${cart.deliveryFee.toStringAsFixed(2)}',
                          isHighlight: cart.deliveryFee == 0,
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Estimated Total',
                              style: GoogleFonts.playfairDisplay(fontSize: 17, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '\$${cart.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Bottom Checkout Button
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
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CheckoutScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Proceed to Delivery Details'),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddonSuggestionCard extends StatelessWidget {
  final GiftAddon addon;

  const _AddonSuggestionCard({required this.addon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              addon.imageUrl,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 54,
                height: 54,
                color: AppColors.surfaceVariant,
                child: Text(addon.iconEmoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  addon.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                Text(
                  '+\$${addon.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isDiscount;
  final bool isHighlight;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.isDiscount = false,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDiscount
                ? AppColors.success
                : isHighlight
                    ? AppColors.primary
                    : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
