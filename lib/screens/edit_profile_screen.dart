import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../providers/address_provider.dart';
import '../models/delivery_address.dart';
import '../theme/app_colors.dart';
import '../widgets/address_form_dialog.dart';
import 'address_book_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  String? _previewAvatarUrl;

  final List<String> _presetAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1561181286-d3fee7d55364?w=200&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?w=200&auto=format&fit=crop&q=80',
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.displayName);
    _phoneController = TextEditingController(text: auth.phoneNumber);
    _previewAvatarUrl = auth.photoURL;

    // Sync AddressProvider with current user id
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().updateUser(auth.user?.uid);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploadingAvatar = true);
      final Uint8List bytes = await image.readAsBytes();
      final auth = context.read<AuthProvider>();

      final uploadedUrl = await auth.uploadAvatarBytes(bytes, image.name);
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
          if (uploadedUrl != null) {
            _previewAvatarUrl = uploadedUrl;
          }
        });

        if (uploadedUrl != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avatar uploaded & synchronized with Firebase Storage!'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload avatar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _choosePresetAvatar() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Botanical Member Avatar',
              style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: _presetAvatars.map((url) {
                return InkWell(
                  onTap: () {
                    setState(() => _previewAvatarUrl = url);
                    Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _previewAvatarUrl == url ? AppColors.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(url),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final auth = context.read<AuthProvider>();

    final success = await auth.updateProfile(
      displayName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      photoURL: _previewAvatarUrl,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Failed to update profile'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final addresses = addressProvider.addresses;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile & Address Book'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Information Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 12,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Avatar with Upload button
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 46,
                                backgroundColor: AppColors.primary,
                                backgroundImage: _previewAvatarUrl != null
                                    ? NetworkImage(_previewAvatarUrl!)
                                    : null,
                                child: _isUploadingAvatar
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : (_previewAvatarUrl == null
                                        ? Text(
                                            auth.initials,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 26,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          )
                                        : null),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: PopupMenuButton<String>(
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: const [
                                        BoxShadow(color: AppColors.shadow, blurRadius: 6),
                                      ],
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                                  ),
                                  onSelected: (val) {
                                    if (val == 'upload') {
                                      _pickAndUploadAvatar();
                                    } else if (val == 'preset') {
                                      _choosePresetAvatar();
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'upload',
                                      child: Row(
                                        children: [
                                          Icon(Icons.upload_file_rounded, size: 18, color: AppColors.primary),
                                          SizedBox(width: 10),
                                          Text('Upload from Device (Firebase)'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'preset',
                                      child: Row(
                                        children: [
                                          Icon(Icons.spa_rounded, size: 18, color: AppColors.accentRose),
                                          SizedBox(width: 10),
                                          Text('Choose Floral Member Avatar'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Click the camera to upload an avatar to Firebase Storage',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Full Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name *',
                            hintText: 'Lady Catherine de Bourgh',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 16),

                        // Phone Number
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Contact Phone Number *',
                            hintText: '+66 81 234 5678',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your phone number' : null,
                        ),
                        const SizedBox(height: 16),

                        // Email (Read Only with Verified Badge)
                        TextFormField(
                          initialValue: auth.email,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Email Address (Verified)',
                            prefixIcon: const Icon(Icons.email_outlined),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                                  SizedBox(width: 4),
                                  Text(
                                    'Active',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveProfile,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.save_rounded, size: 18),
                            label: Text(
                              _isSaving ? 'Saving Changes...' : 'Save Profile Changes',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Address Book Sub-section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Address Book',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Manage your home, office, and recipient delivery addresses',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => AddressFormDialog.show(context),
                        icon: const Icon(Icons.add_location_alt_rounded, size: 16),
                        label: const Text('Add Address', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Addresses List
                  if (addresses.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.place_outlined, size: 42, color: AppColors.textLight),
                            const SizedBox(height: 10),
                            const Text('No addresses in your address book yet.'),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => AddressFormDialog.show(context),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Delivery Address'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: addresses.map((addr) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: addr.isDefault ? AppColors.primary : AppColors.border,
                              width: addr.isDefault ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      addr.label,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (addr.isDefault)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGoldLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'DEFAULT',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.accentGold,
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 17, color: AppColors.textSecondary),
                                    tooltip: 'Edit',
                                    splashRadius: 18,
                                    onPressed: () => AddressFormDialog.show(context, address: addr),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 17, color: AppColors.error),
                                    tooltip: 'Delete',
                                    splashRadius: 18,
                                    onPressed: () => addressProvider.deleteAddress(addr.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${addr.recipientName} • ${addr.phoneNumber}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                addr.fullAddress,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              if (addr.note != null && addr.note!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Note: ${addr.note}',
                                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textLight),
                                ),
                              ],
                              const SizedBox(height: 10),
                              if (!addr.isDefault)
                                TextButton.icon(
                                  onPressed: () => addressProvider.setDefaultAddress(addr.id),
                                  icon: const Icon(Icons.check_circle_outline, size: 15, color: AppColors.primary),
                                  label: const Text('Set as Default Address', style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
