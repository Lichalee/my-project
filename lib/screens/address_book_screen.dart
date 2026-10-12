import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/delivery_address.dart';
import '../providers/address_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/address_form_dialog.dart';

class AddressBookScreen extends StatelessWidget {
  final bool selectMode;
  final ValueChanged<DeliveryAddress>? onSelect;

  const AddressBookScreen({
    super.key,
    this.selectMode = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();
    final addresses = addressProvider.addresses;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(selectMode ? 'Select Delivery Address' : 'Address Book'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Header Summary Banner
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery Addresses (${addresses.length})',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Saved addresses are synchronized with your Firestore account.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => AddressFormDialog.show(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Address', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // Address Cards List
              Expanded(
                child: addresses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.place_outlined, size: 56, color: AppColors.primary),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Saved Addresses Yet',
                              style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Add your home, office, or gift destination addresses.',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => AddressFormDialog.show(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add First Address'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          final addr = addresses[index];
                          return _AddressCard(
                            address: addr,
                            selectMode: selectMode,
                            onSelect: () {
                              if (selectMode) {
                                onSelect?.call(addr);
                                Navigator.pop(context, addr);
                              }
                            },
                            onEdit: () => AddressFormDialog.show(context, address: addr),
                            onDelete: () => _confirmDelete(context, addressProvider, addr),
                            onSetDefault: () => addressProvider.setDefaultAddress(addr.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AddressProvider provider, DeliveryAddress addr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Address?'),
        content: Text('Are you sure you want to remove "${addr.label} - ${addr.recipientName}" from your Address Book?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteAddress(addr.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Address deleted'), backgroundColor: AppColors.error),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final DeliveryAddress address;
  final bool selectMode;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.selectMode,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'office':
        return Icons.apartment_rounded;
      case 'gift recipient':
        return Icons.card_giftcard_rounded;
      case 'penthouse':
        return Icons.star_border_rounded;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: address.isDefault ? AppColors.primary : AppColors.border,
          width: address.isDefault ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: selectMode ? onSelect : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top label & Default pill
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getIconForLabel(address.label), size: 14, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(
                          address.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.accentGoldLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 13, color: AppColors.accentGold),
                          SizedBox(width: 4),
                          Text(
                            'DEFAULT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentGold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  // Edit & Delete icons
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                    tooltip: 'Edit Address',
                    splashRadius: 18,
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    tooltip: 'Delete Address',
                    splashRadius: 18,
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recipient info
              Row(
                children: [
                  Text(
                    address.recipientName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    address.phoneNumber,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Full Address text
              Text(
                address.fullAddress,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
              ),

              // Delivery note if any
              if (address.note != null && address.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          address.note!,
                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Bottom actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!address.isDefault)
                    TextButton.icon(
                      onPressed: onSetDefault,
                      icon: const Icon(Icons.radio_button_unchecked, size: 16, color: AppColors.primary),
                      label: const Text('Set as Default', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    )
                  else
                    const Row(
                      children: [
                        Icon(Icons.radio_button_checked, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'Default delivery address',
                          style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  if (selectMode)
                    ElevatedButton(
                      onPressed: onSelect,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Select Address', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
