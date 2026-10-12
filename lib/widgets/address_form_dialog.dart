import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/delivery_address.dart';
import '../providers/address_provider.dart';
import '../theme/app_colors.dart';

class AddressFormDialog extends StatefulWidget {
  final DeliveryAddress? initialAddress;

  const AddressFormDialog({super.key, this.initialAddress});

  static Future<bool?> show(BuildContext context, {DeliveryAddress? address}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AddressFormDialog(initialAddress: address),
    );
  }

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedLabel;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _subDistrictController;
  late TextEditingController _districtController;
  late TextEditingController _provinceController;
  late TextEditingController _postalCodeController;
  late TextEditingController _noteController;
  late bool _isDefault;
  bool _isSaving = false;

  final List<String> _labels = ['Home', 'Office', 'Gift Recipient', 'Penthouse', 'Other'];

  @override
  void initState() {
    super.initState();
    final addr = widget.initialAddress;
    _selectedLabel = addr?.label ?? 'Home';
    _nameController = TextEditingController(text: addr?.recipientName ?? '');
    _phoneController = TextEditingController(text: addr?.phoneNumber ?? '');
    _streetController = TextEditingController(text: addr?.streetAddress ?? '');
    _subDistrictController = TextEditingController(text: addr?.subDistrict ?? '');
    _districtController = TextEditingController(text: addr?.district ?? '');
    _provinceController = TextEditingController(text: addr?.province ?? 'Bangkok');
    _postalCodeController = TextEditingController(text: addr?.postalCode ?? '');
    _noteController = TextEditingController(text: addr?.note ?? '');
    _isDefault = addr?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _subDistrictController.dispose();
    _districtController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<AddressProvider>();

    final addressData = DeliveryAddress(
      id: widget.initialAddress?.id ?? '',
      label: _selectedLabel,
      recipientName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      streetAddress: _streetController.text.trim(),
      subDistrict: _subDistrictController.text.trim(),
      district: _districtController.text.trim(),
      province: _provinceController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      isDefault: _isDefault,
      createdAt: widget.initialAddress?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (widget.initialAddress != null) {
      success = await provider.updateAddress(addressData);
    } else {
      success = await provider.addAddress(addressData);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.initialAddress != null
                  ? 'Delivery address updated successfully'
                  : 'New address added to your Address Book',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save address: ${provider.error ?? "Unknown error"}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialAddress != null;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.place_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Edit Delivery Address' : 'Add New Address',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label selector
                        const Text(
                          'Address Type / Tag',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _labels.map((lbl) {
                            final isSel = _selectedLabel == lbl;
                            return ChoiceChip(
                              label: Text(lbl),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel ? Colors.white : AppColors.textPrimary,
                              ),
                              backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                              side: BorderSide(
                                color: isSel ? AppColors.primary : AppColors.border,
                              ),
                              onSelected: (_) => setState(() => _selectedLabel = lbl),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Recipient Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Recipient Full Name *',
                            hintText: 'e.g., Jane Austen',
                            prefixIcon: Icon(Icons.person_outline, size: 20),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter recipient name' : null,
                        ),
                        const SizedBox(height: 14),

                        // Phone Number
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Contact Phone Number *',
                            hintText: 'e.g., +66 81 234 5678',
                            prefixIcon: Icon(Icons.phone_outlined, size: 20),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter phone number' : null,
                        ),
                        const SizedBox(height: 14),

                        // Street Address
                        TextFormField(
                          controller: _streetController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'House / Building / Street Address *',
                            hintText: 'e.g., 88/12 Thonglor Soi 10, Sukhumvit 55',
                            prefixIcon: Icon(Icons.home_outlined, size: 20),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter street address' : null,
                        ),
                        const SizedBox(height: 14),

                        // Sub-district & District
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _subDistrictController,
                                decoration: const InputDecoration(
                                  labelText: 'Sub-district (แขวง)',
                                  hintText: 'Khlong Tan Nuea',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _districtController,
                                decoration: const InputDecoration(
                                  labelText: 'District (เขต)',
                                  hintText: 'Watthana',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Province & Postal Code
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _provinceController,
                                decoration: const InputDecoration(
                                  labelText: 'Province (จังหวัด)',
                                  hintText: 'Bangkok',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _postalCodeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Postal Code *',
                                  hintText: '10110',
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Delivery Note
                        TextFormField(
                          controller: _noteController,
                          decoration: const InputDecoration(
                            labelText: 'Delivery Instructions (Optional)',
                            hintText: 'e.g., Leave with condo concierge, Gate code #1234',
                            prefixIcon: Icon(Icons.notes_rounded, size: 20),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Default Address switch
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Set as Default Delivery Address',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text(
                              'This address will be automatically selected during checkout.',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            value: _isDefault,
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() => _isDefault = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveAddress,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(_isSaving ? 'Saving...' : (isEditing ? 'Update Address' : 'Save Address')),
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
