import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../models/order_model.dart';
import '../theme/app_colors.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String? orderId;

  const OrderTrackingScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final order = (orderId != null
            ? orderProvider.orders.firstWhere((o) => o.id == orderId, orElse: () => orderProvider.orders.first)
            : orderProvider.activeTrackingOrder) ??
        (orderProvider.orders.isNotEmpty ? orderProvider.orders.first : null);

    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Delivery Tracker')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_shipping_outlined, size: 64, color: AppColors.textLight),
              const SizedBox(height: 16),
              Text(
                'No Active Orders Found',
                style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Place an order for fresh flowers to track delivery in real time.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order #${order.id}'),
        actions: [
          // Interactive Demo Button to advance status
          TextButton.icon(
            onPressed: () {
              orderProvider.advanceOrderStatus(order.id);
            },
            icon: const Icon(Icons.fast_forward_rounded, size: 16, color: AppColors.primary),
            label: const Text(
              'Simulate Status',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order.status.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Text(
                        'ETA: Today by 05:00 PM',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order.status.title,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.status.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Live Timeline Steps
            Text(
              'Delivery Milestones',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: OrderStatus.values.map((s) {
                  final isPassed = s.stepIndex <= order.status.stepIndex;
                  final isCurrent = s == order.status;
                  final isLast = s.stepIndex == OrderStatus.values.length - 1;

                  return _TimelineTile(
                    status: s,
                    isPassed: isPassed,
                    isCurrent: isCurrent,
                    isLast: isLast,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Chilled Courier Info Card
            Text(
              'Courier & Chilled Transport',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryLight.withValues(alpha: 0.12),
                    child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.courierName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Climate-Controlled Fresh Van',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.courierPhone,
                          style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calling courier ${order.courierName}...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone, size: 18, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Delivery Details Summary
            Text(
              'Recipient Destination',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_pin_circle_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Deliver to: ${order.recipientName}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Text(
                      order.deliveryAddress,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                  if (order.deliveryInstructions != null && order.deliveryInstructions!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 28),
                      child: Text(
                        'Note for Driver: "${order.deliveryInstructions}"',
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.accentGold),
                      ),
                    ),
                  ],
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Scheduled: ${dateFormat.format(order.deliveryDate)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Text(
                        order.deliveryTimeSlot.split('(').first.trim(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ],
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
}

class _TimelineTile extends StatelessWidget {
  final OrderStatus status;
  final bool isPassed;
  final bool isCurrent;
  final bool isLast;

  const _TimelineTile({
    required this.status,
    required this.isPassed,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isPassed ? AppColors.primary : AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent ? AppColors.accentGold : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: isPassed
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.textLight, shape: BoxShape.circle)),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isPassed ? AppColors.primary : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                    color: isPassed ? AppColors.textPrimary : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isPassed ? AppColors.textSecondary : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
