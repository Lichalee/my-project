import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/flower_product.dart';
import '../providers/shop_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/delivery_date_sheet.dart';

class ProductDetailScreen extends StatefulWidget {
  final FlowerProduct product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late String _selectedSize;
  int _quantity = 1;
  late DateTime _deliveryDate;
  late String _deliverySlot;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  bool _includeCard = false;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.sizeVariants.first.name;
    final cart = context.read<CartProvider>();
    _deliveryDate = cart.selectedDeliveryDate;
    _deliverySlot = cart.selectedDeliverySlot;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = context.watch<ShopProvider>();
    final cartProvider = context.read<CartProvider>();
    final isFav = shopProvider.isFavorite(widget.product.id);
    final currentPrice = widget.product.getPriceForSize(_selectedSize) * _quantity;
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Image Header
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: AppColors.surface,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.85),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.85),
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? AppColors.accentRose : AppColors.textPrimary,
                          size: 20,
                        ),
                        onPressed: () => shopProvider.toggleFavorite(widget.product.id),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.local_florist, size: 80, color: AppColors.primaryLight),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.background,
                                AppColors.background.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Product Info & Controls
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & Fragrance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.product.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                widget.product.rating.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${widget.product.reviewCount} reviews)',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title & Botanical Name
                      Text(
                        widget.product.name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.botanicalName,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botanical Specs Bar (Stems, Vase Life, Fragrance)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _SpecItem(
                              icon: Icons.local_florist_outlined,
                              label: 'Stem Count',
                              value: '${widget.product.stemCount} stems',
                            ),
                            Container(width: 1, height: 32, color: AppColors.border),
                            _SpecItem(
                              icon: Icons.hourglass_top_rounded,
                              label: 'Vase Life',
                              value: '${widget.product.vaseLifeDays} days',
                            ),
                            Container(width: 1, height: 32, color: AppColors.border),
                            _SpecItem(
                              icon: Icons.air_rounded,
                              label: 'Fragrance',
                              value: '${widget.product.fragranceLevel}/5 intensity',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      Text(
                        'About this Arrangement',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.description,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Size Variants Selection
                      Text(
                        'Select Arrangement Size',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: widget.product.sizeVariants.map((variant) {
                          final isSelected = _selectedSize == variant.name;
                          final variantPrice = widget.product.basePrice * variant.priceMultiplier;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSize = variant.name;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryLight.withValues(alpha: 0.08)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.border,
                                  width: isSelected ? 1.5 : 1.0,
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          variant.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          variant.stemDescription,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${variantPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Delivery Date & Slot Selector
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Delivery Schedule',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    DeliveryDateSheet.show(
                                      context: context,
                                      initialDate: _deliveryDate,
                                      initialSlot: _deliverySlot,
                                      onSelected: (date, slot) {
                                        setState(() {
                                          _deliveryDate = date;
                                          _deliverySlot = slot;
                                        });
                                      },
                                    );
                                  },
                                  child: const Text('Change Date', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '📅 ${dateFormat.format(_deliveryDate)}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '⏰ $_deliverySlot',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Care Guide Accordion
                      ExpansionTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        backgroundColor: AppColors.surface,
                        collapsedBackgroundColor: AppColors.surface,
                        leading: const Icon(Icons.eco_rounded, color: AppColors.primary),
                        title: const Text(
                          'Flower Care & Longevity Guide',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: widget.product.careInstructions.map((tip) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                      Expanded(
                                        child: Text(
                                          tip,
                                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Optional Free Greeting Card Accordion
                      CheckboxListTile(
                        value: _includeCard,
                        onChanged: (val) {
                          setState(() {
                            _includeCard = val ?? false;
                          });
                        },
                        title: const Text('Add Complimentary Handwritten Note Card', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Included with our botanical wax seal', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_includeCard) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: _recipientController,
                          decoration: const InputDecoration(
                            labelText: 'Recipient Name',
                            hintText: 'e.g. Dearest Sophia',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _messageController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Card Message',
                            hintText: 'Write your heartfelt message here...',
                          ),
                        ),
                      ],
                      const SizedBox(height: 100), // padding for sticky bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Bottom Bar with Price & Add to Cart
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
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
                    // Quantity Stepper
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Add to Cart Button with total price
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          cartProvider.addFlowerProduct(
                            widget.product,
                            selectedSize: _selectedSize,
                            quantity: _quantity,
                            recipient: _includeCard ? _recipientController.text : null,
                            greetingMessage: _includeCard ? _messageController.text : null,
                            date: _deliveryDate,
                            slot: _deliverySlot,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added $_quantity x ${widget.product.name} to Cart!'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text('Add to Cart • \$${currentPrice.toStringAsFixed(0)}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textLight),
        ),
      ],
    );
  }
}
