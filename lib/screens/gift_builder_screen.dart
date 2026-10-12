import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/gift_builder_provider.dart';
import '../providers/cart_provider.dart';
import '../models/custom_gift_box.dart';
import '../theme/app_colors.dart';
import '../widgets/gift_card_preview.dart';
import '../data/mock_data.dart';

class GiftBuilderScreen extends StatefulWidget {
  final VoidCallback? onCompleted;

  const GiftBuilderScreen({super.key, this.onCompleted});

  @override
  State<GiftBuilderScreen> createState() => _GiftBuilderScreenState();
}

class _GiftBuilderScreenState extends State<GiftBuilderScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _ribbonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<GiftBuilderProvider>();
    _recipientController.text = provider.cardRecipient;
    _messageController.text = provider.cardMessage;
    _senderController.text = provider.cardSender;
    _ribbonController.text = provider.ribbonText;
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    _senderController.dispose();
    _ribbonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final builder = context.watch<GiftBuilderProvider>();
    final cart = context.read<CartProvider>();

    return Scaffold(
      body: Column(
        children: [
          // Sub-header with Title and Reset action
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bespoke Gift Studio',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    builder.reset();
                    _recipientController.text = builder.cardRecipient;
                    _messageController.text = builder.cardMessage;
                    _senderController.text = builder.cardSender;
                    _ribbonController.text = builder.ribbonText;
                  },
                  icon: const Icon(Icons.refresh, size: 16, color: AppColors.accentRose),
                  label: const Text('Reset', style: TextStyle(color: AppColors.accentRose, fontSize: 13)),
                ),
              ],
            ),
          ),
          // Step Progress Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppColors.surface,
            child: Row(
              children: [
                _buildStepPill(0, '1. Box', builder.currentStep),
                _buildStepDivider(builder.currentStep >= 1),
                _buildStepPill(1, '2. Flowers', builder.currentStep),
                _buildStepDivider(builder.currentStep >= 2),
                _buildStepPill(2, '3. Treats', builder.currentStep),
                _buildStepDivider(builder.currentStep >= 3),
                _buildStepPill(3, '4. Card', builder.currentStep),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentStepView(builder),
            ),
          ),

          // Floating Summary & Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                  // Price breakdown preview
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Hamper Value',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      Text(
                        '\$${builder.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Back Button (if not step 0)
                  if (builder.currentStep > 0) ...[
                    OutlinedButton(
                      onPressed: () => builder.previousStep(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Icon(Icons.arrow_back, size: 18),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Next / Finish Button
                  if (builder.currentStep < 3)
                    ElevatedButton(
                      onPressed: () => builder.nextStep(),
                      child: const Row(
                        children: [
                          Text('Next Step'),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        final giftBox = builder.buildGiftBox();
                        cart.addCustomGiftBox(giftBox);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bespoke Gift Box added to your Cart!'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        if (widget.onCompleted != null) {
                          widget.onCompleted!();
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Add Box to Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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

  Widget _buildStepPill(int step, String label, int currentStep) {
    final isDone = currentStep > step;
    final isCurrent = currentStep == step;

    return GestureDetector(
      onTap: () => context.read<GiftBuilderProvider>().setStep(step),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.primary
              : isDone
                  ? AppColors.primaryLight.withValues(alpha: 0.15)
                  : AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent
                ? Colors.white
                : isDone
                    ? AppColors.primary
                    : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStepDivider(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: active ? AppColors.primaryLight : AppColors.border,
      ),
    );
  }

  Widget _buildCurrentStepView(GiftBuilderProvider builder) {
    switch (builder.currentStep) {
      case 0:
        return _buildPackagingStep(builder);
      case 1:
        return _buildFloralStep(builder);
      case 2:
        return _buildAddonsStep(builder);
      case 3:
      default:
        return _buildCardAndRibbonStep(builder);
    }
  }

  // Step 0: Packaging & Vessel Selection
  Widget _buildPackagingStep(GiftBuilderProvider builder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Vessel & Packaging',
          style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'The luxury foundation for your handcrafted floral arrangement.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        Column(
          children: PackagingType.values.map((pkg) {
            final isSelected = builder.selectedPackaging == pkg;
            return GestureDetector(
              onTap: () => builder.selectPackaging(pkg),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppColors.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(pkg.iconEmoji, style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pkg.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pkg.description,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '+\$${pkg.basePrice.toStringAsFixed(0)}',
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
      ],
    );
  }

  // Step 1: Floral Palette Theme
  Widget _buildFloralStep(GiftBuilderProvider builder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Floral Harmony',
          style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'Choose the signature color mood and focal fresh blooms.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        Column(
          children: FloralPalette.values.map((pal) {
            final isSelected = builder.selectedPalette == pal;
            return GestureDetector(
              onTap: () => builder.selectPalette(pal),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
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
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(pal.colorHex),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12, width: 1),
                      ),
                      child: const Center(
                        child: Text('🌸', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pal.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pal.description,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '+\$${pal.price.toStringAsFixed(0)}',
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
      ],
    );
  }

  // Step 2: Add-on Delights (Chocolates, Candle, Macarons, etc.)
  Widget _buildAddonsStep(GiftBuilderProvider builder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Gourmet Delights & Treats',
          style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select curated artisan treats to place inside your gift hamper.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        Column(
          children: MockData.giftAddons.map((addon) {
            final isSelected = builder.isAddonSelected(addon.id);

            return GestureDetector(
              onTap: () => builder.toggleAddon(addon),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        addon.imageUrl,
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 58,
                          height: 58,
                          color: AppColors.surfaceVariant,
                          child: Text(addon.iconEmoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            addon.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            addon.description,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+\$${addon.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                          color: isSelected ? AppColors.primary : AppColors.textLight,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Step 3: Personalized Greeting Note & Wax Seal
  Widget _buildCardAndRibbonStep(GiftBuilderProvider builder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personalize Note & Silk Ribbon',
          style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'Real-time live stationery preview of what your recipient will read.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),

        // Live Stationery Preview
        GiftCardPreview(
          recipient: builder.cardRecipient,
          message: builder.cardMessage,
          sender: builder.cardSender,
          cardDesign: builder.cardDesign,
          hasWaxSeal: builder.hasWaxSeal,
          waxSealColor: builder.waxSealColor,
          ribbonText: builder.ribbonText,
        ),
        const SizedBox(height: 24),

        // Form Fields
        Text(
          'Customize Stationery Text',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _recipientController,
          onChanged: (v) => builder.updateCardDetails(recipient: v),
          decoration: const InputDecoration(
            labelText: 'Recipient Name',
            hintText: 'e.g. My Dearest Sophia',
            prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageController,
          onChanged: (v) => builder.updateCardDetails(message: v),
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Your Note Card Message',
            hintText: 'Express your feelings, congratulations, or love...',
            prefixIcon: Icon(Icons.edit_note, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _senderController,
          onChanged: (v) => builder.updateCardDetails(sender: v),
          decoration: const InputDecoration(
            labelText: 'Sender Name / Sign-off',
            hintText: 'e.g. Julian / Secret Admirer',
            prefixIcon: Icon(Icons.favorite_outline, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ribbonController,
          onChanged: (v) => builder.updateRibbonText(v),
          decoration: const InputDecoration(
            labelText: 'Embroidered Silk Ribbon Text (+\$2.00)',
            hintText: 'e.g. Forever Yours, Happy Birthday, Just Because',
            prefixIcon: Icon(Icons.bookmark_outline, color: AppColors.accentGold),
          ),
        ),
        const SizedBox(height: 20),

        // Wax Seal Option
        SwitchListTile(
          value: builder.hasWaxSeal,
          onChanged: (v) => builder.updateCardDetails(waxSeal: v),
          activeTrackColor: AppColors.accentGold,
          title: const Text('Add Authentic Hot Wax Seal (+\$3.50)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          subtitle: const Text('Hand-stamped with golden botanical insignia', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          contentPadding: EdgeInsets.zero,
        ),
        if (builder.hasWaxSeal) ...[
          const SizedBox(height: 8),
          const Text('Wax Stamp Color:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: builder.availableWaxSeals.map((seal) {
              final isSel = builder.waxSealColor == seal;
              return ChoiceChip(
                label: Text(seal),
                selected: isSel,
                onSelected: (_) => builder.updateCardDetails(sealColor: seal),
                selectedColor: AppColors.accentGoldLight,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isSel ? AppColors.accentGold : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }
}
