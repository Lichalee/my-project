import 'cart_item.dart';

enum OrderStatus {
  confirmed(
    title: 'Order Confirmed',
    description: 'We have received your order and payment.',
    stepIndex: 0,
  ),
  arranging(
    title: 'Arranging by Artisan Florist',
    description: 'Our master florists are handcrafting your floral arrangement.',
    stepIndex: 1,
  ),
  outForDelivery(
    title: 'Out for Delivery',
    description: 'Chilled courier van is on the way to the recipient.',
    stepIndex: 2,
  ),
  delivered(
    title: 'Delivered with Care',
    description: 'Package has been hand-delivered directly to recipient.',
    stepIndex: 3,
  );

  final String title;
  final String description;
  final int stepIndex;

  const OrderStatus({
    required this.title,
    required this.description,
    required this.stepIndex,
  });
}

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final String deliveryTimeSlot;
  final String recipientName;
  final String recipientPhone;
  final String deliveryAddress;
  final String? deliveryInstructions;
  final String senderName;
  final bool isAnonymous;
  final String? greetingCardMessage;
  OrderStatus status;
  final String paymentMethod;
  final String courierName;
  final String courierPhone;
  final String? deliveryProofPhotoUrl;

  OrderModel({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.orderDate,
    required this.deliveryDate,
    required this.deliveryTimeSlot,
    required this.recipientName,
    required this.recipientPhone,
    required this.deliveryAddress,
    this.deliveryInstructions,
    required this.senderName,
    this.isAnonymous = false,
    this.greetingCardMessage,
    this.status = OrderStatus.confirmed,
    required this.paymentMethod,
    this.courierName = 'Oliver Vance (Chilled Van #04)',
    this.courierPhone = '+1 (555) 234-8891',
    this.deliveryProofPhotoUrl,
  });
}
