import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../models/cart_item.dart';
import '../models/occasion_reminder.dart';
import '../data/mock_data.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [];
  final List<OccasionReminder> _reminders = [];
  String? _activeTrackingOrderId;

  OrderProvider() {
    _reminders.addAll(MockData.initialReminders);

    // Initial Demo Active Order
    final demoOrder = OrderModel(
      id: 'BR-84920',
      items: [
        CartItem(
          id: const Uuid().v4(),
          flowerProduct: MockData.flowerProducts[0], // Scarlet Reverie
          selectedSizeName: 'Deluxe',
          quantity: 1,
          greetingMessage: 'Happy 5th Anniversary my love! You are my forever bloom.',
          recipientName: 'Genevieve Vance',
        ),
      ],
      subtotal: 106.65,
      deliveryFee: 0.0,
      discount: 10.66,
      total: 95.99,
      orderDate: DateTime.now().subtract(const Duration(hours: 3)),
      deliveryDate: DateTime.now(),
      deliveryTimeSlot: 'Afternoon Serenade (01:00 PM - 05:00 PM)',
      recipientName: 'Genevieve Vance',
      recipientPhone: '+1 (555) 789-3342',
      deliveryAddress: '742 Evergreen Terrace, Apt 4B, Springfield',
      deliveryInstructions: 'Ring doorbell twice, leave with concierge if unavailable.',
      senderName: 'Julian Sterling',
      status: OrderStatus.outForDelivery,
      paymentMethod: 'Apple Pay',
      courierName: 'Arthur Hastings (Van #02)',
      courierPhone: '+1 (555) 912-3847',
      deliveryProofPhotoUrl: 'https://images.unsplash.com/photo-1561181286-d3fee7d55364?w=400&auto=format&fit=crop&q=80',
    );

    _orders.add(demoOrder);
    _activeTrackingOrderId = demoOrder.id;
  }

  List<OrderModel> get orders => List.unmodifiable(_orders);
  List<OccasionReminder> get reminders => List.unmodifiable(_reminders);
  String? get activeTrackingOrderId => _activeTrackingOrderId;

  OrderModel? get activeTrackingOrder {
    if (_activeTrackingOrderId == null) {
      return _orders.isNotEmpty ? _orders.first : null;
    }
    try {
      return _orders.firstWhere((o) => o.id == _activeTrackingOrderId);
    } catch (_) {
      return _orders.isNotEmpty ? _orders.first : null;
    }
  }

  void setActiveTrackingOrderId(String orderId) {
    _activeTrackingOrderId = orderId;
    notifyListeners();
  }

  OrderModel createOrder({
    required List<CartItem> items,
    required double subtotal,
    required double deliveryFee,
    required double discount,
    required double total,
    required DateTime deliveryDate,
    required String deliveryTimeSlot,
    required String recipientName,
    required String recipientPhone,
    required String deliveryAddress,
    String? deliveryInstructions,
    required String senderName,
    bool isAnonymous = false,
    String? greetingCardMessage,
    required String paymentMethod,
  }) {
    final newOrder = OrderModel(
      id: 'BR-${(10000 + _orders.length * 77 + (DateTime.now().millisecondsSinceEpoch % 89999)).toString()}',
      items: List.from(items),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      orderDate: DateTime.now(),
      deliveryDate: deliveryDate,
      deliveryTimeSlot: deliveryTimeSlot,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      deliveryAddress: deliveryAddress,
      deliveryInstructions: deliveryInstructions,
      senderName: senderName,
      isAnonymous: isAnonymous,
      greetingCardMessage: greetingCardMessage,
      status: OrderStatus.confirmed,
      paymentMethod: paymentMethod,
    );

    _orders.insert(0, newOrder);
    _activeTrackingOrderId = newOrder.id;
    notifyListeners();
    return newOrder;
  }

  void advanceOrderStatus(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final current = _orders[index].status;
      switch (current) {
        case OrderStatus.confirmed:
          _orders[index].status = OrderStatus.arranging;
          break;
        case OrderStatus.arranging:
          _orders[index].status = OrderStatus.outForDelivery;
          break;
        case OrderStatus.outForDelivery:
          _orders[index].status = OrderStatus.delivered;
          break;
        case OrderStatus.delivered:
          // Stay delivered
          break;
      }
      notifyListeners();
    }
  }

  void addReminder(OccasionReminder reminder) {
    _reminders.add(reminder);
    _reminders.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    notifyListeners();
  }

  void removeReminder(String id) {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
