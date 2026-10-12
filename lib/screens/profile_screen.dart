import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../models/occasion_reminder.dart';
import '../theme/app_colors.dart';
import 'order_tracking_screen.dart';
import 'favorites_screen.dart';
import 'auth_screen.dart';
import 'todo_notes_screen.dart';
import 'edit_profile_screen.dart';
import 'address_book_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onSendFlowers;

  const ProfileScreen({super.key, this.onSendFlowers});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final authProvider = context.watch<AuthProvider>();
    final reminders = orderProvider.reminders;
    final isAuthenticated = authProvider.isAuthenticated;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sub-header with Title and Sign Out
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Floral Account',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isAuthenticated)
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
                    tooltip: 'Sign Out',
                    onPressed: () => _confirmSignOut(context),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            // User Header Card / Guest Card
            if (isAuthenticated)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      backgroundImage: authProvider.photoURL != null
                          ? NetworkImage(authProvider.photoURL!)
                          : null,
                      child: authProvider.photoURL == null
                          ? Text(
                              authProvider.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.displayName,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            authProvider.email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accentGoldLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('⚜️ ', style: TextStyle(fontSize: 10)),
                                Text(
                                  'Bloom & Ribbon VIP Member',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accentGold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                      tooltip: 'Edit Profile & Address Book',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                      },
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🌿 ', style: TextStyle(fontSize: 22)),
                        Text(
                          'Join Bloom & Ribbon Club',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in to sync your reminders, view order status, and unlock complimentary floral care.',
                      style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AuthScreen(initialIsRegister: false)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AuthScreen(initialIsRegister: true)),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Register', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 28),

            // Occasion Reminders Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Occasion Reminders',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                TextButton.icon(
                  onPressed: () => _showAddReminderDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Date', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (reminders.isEmpty)
              const Text('No occasion reminders saved yet.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))
            else
              Column(
                children: reminders.map((rem) {
                  return _ReminderCard(
                    reminder: rem,
                    onSendFlowers: onSendFlowers,
                    onDelete: () => orderProvider.removeReminder(rem.id),
                  );
                }).toList(),
              ),
            const SizedBox(height: 28),

            // Account Shortcuts List
            Text(
              'Order & Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _ProfileTile(
                    icon: Icons.task_alt_rounded,
                    title: 'Tasks & Floral Notes',
                    subtitle: 'Real-time synced personal checklist & reminders',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TodoNotesScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _ProfileTile(
                    icon: Icons.history_rounded,
                    title: 'Order History & Receipts',
                    subtitle: '${orderProvider.orders.length} orders placed',
                    onTap: () {
                      if (orderProvider.orders.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderTrackingScreen(orderId: orderProvider.orders.first.id),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No past orders yet.')),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _ProfileTile(
                    icon: Icons.favorite_border_rounded,
                    title: 'My Wishlist',
                    subtitle: 'Saved favorite bouquets and arrangements',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FavoritesScreen(onExplore: onSendFlowers),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _ProfileTile(
                    icon: Icons.place_outlined,
                    title: 'Saved Delivery Addresses',
                    subtitle: 'Manage default shipping destinations & instructions',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddressBookScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _ProfileTile(
                    icon: Icons.eco_outlined,
                    title: 'Flower Care Masterclass',
                    subtitle: 'Guide to keeping fresh stems vibrant for 14+ days',
                    onTap: () {
                      _showInfoModal(
                        context,
                        'Artisan Care Tips',
                        '1. Cut stems 45° underwater.\n2. Keep out of direct sun & away from fruits.\n3. Refresh clean water daily.\n4. Use our complimentary nutrient pack.',
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _ProfileTile(
                    icon: Icons.headset_mic_outlined,
                    title: '24/7 Florist Concierge',
                    subtitle: 'Direct line to our Master Florist team',
                    onTap: () {
                      _showInfoModal(context, 'Bespoke Concierge', 'Call our floral concierge anytime at:\n+1 (800) 555-BLOOM\n\nOr email concierge@bloomandribbon.com');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign Out', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out of your floral account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You have been signed out.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showInfoModal(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        content: Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final titleController = TextEditingController();
    final recipientController = TextEditingController();
    DateTime pickedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Occasion Reminder', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Occasion Title (e.g. Sister\'s Birthday)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: recipientController,
                decoration: const InputDecoration(labelText: 'Recipient Name'),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Date: ${DateFormat('MMM d, yyyy').format(pickedDate)}'),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: pickedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => pickedDate = picked);
                      }
                    },
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  context.read<OrderProvider>().addReminder(
                        OccasionReminder(
                          id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
                          title: titleController.text.trim(),
                          recipient: recipientController.text.trim().isEmpty ? 'Loved One' : recipientController.text.trim(),
                          date: pickedDate,
                          occasionType: 'Special Occasion',
                          suggestedFlower: 'Scarlet Reverie',
                        ),
                      );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final OccasionReminder reminder;
  final VoidCallback? onSendFlowers;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    this.onSendFlowers,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');
    final isSoon = reminder.daysRemaining <= 7;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSoon ? AppColors.accentRose.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSoon ? AppColors.accentRoseLight : AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isSoon ? '⏰' : '📅',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reminder.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    if (isSoon) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentRose,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'SOON',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${dateFormat.format(reminder.date)} (${reminder.daysRemaining} days away) • ${reminder.recipient}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onSendFlowers,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
            child: const Text('Send Blooms'),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.textLight),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textLight),
      onTap: onTap,
    );
  }
}
