import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';
import '../models/flower_product.dart';
import '../models/custom_gift_box.dart';
import '../data/mock_data.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _appliedCoupon;
  double _discountPercentage = 0.0;
  DateTime _selectedDeliveryDate = DateTime.now().add(const Duration(days: 1));
  String _selectedDeliverySlot = MockData.deliveryTimeSlots.first;
  String _recipientName = '';
  String _recipientPhone = '';
  String _deliveryAddress = '';
  String _deliveryNote = '';
  String _senderName = 'Julian Sterling';
  bool _isAnonymous = false;
  String _greetingCardMessage = '';

  // Initial Sample Cart Item
  CartProvider() {
    _items.add(
      CartItem(
        id: const Uuid().v4(),
        flowerProduct: MockData.flowerProducts[1], // Pastel Parisian Melody
        selectedSizeName: 'Deluxe',
        quantity: 1,
        greetingMessage: 'Happy Birthday Sophia! Wishing you endless bloom and joy.',
        recipientName: 'Sophia Montgomery',
        deliveryDate: _selectedDeliveryDate,
        deliveryTimeSlot: _selectedDeliverySlot,
      ),
    );
  }

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  String? get appliedCoupon => _appliedCoupon;
  double get discountPercentage => _discountPercentage;
  DateTime get selectedDeliveryDate => _selectedDeliveryDate;
  String get selectedDeliverySlot => _selectedDeliverySlot;
  String get recipientName => _recipientName;
  String get recipientPhone => _recipientPhone;
  String get deliveryAddress => _deliveryAddress;
  String get deliveryNote => _deliveryNote;
  String get senderName => _senderName;
  bool get isAnonymous => _isAnonymous;
  String get greetingCardMessage => _greetingCardMessage;

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get deliveryFee {
    if (subtotal == 0) return 0.0;
    if (_selectedDeliverySlot.contains('VIP')) return 12.0;
    if (subtotal >= 100.0) return 0.0; // Free delivery over $100
    return 9.0;
  }

  double get discountAmount {
    return subtotal * _discountPercentage;
  }

  double get total {
    return (subtotal - discountAmount + deliveryFee).clamp(0.0, double.infinity);
  }

  void addFlowerProduct(
    FlowerProduct product, {
    String selectedSize = 'Classic',
    int quantity = 1,
    String? greetingMessage,
    String? recipient,
    DateTime? date,
    String? slot,
  }) {
    // Check if same item & size exists
    final existingIndex = _items.indexWhere(
      (item) => item.flowerProduct?.id == product.id && item.selectedSizeName == selectedSize,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          id: const Uuid().v4(),
          flowerProduct: product,
          selectedSizeName: selectedSize,
          quantity: quantity,
          greetingMessage: greetingMessage,
          recipientName: recipient,
          deliveryDate: date ?? _selectedDeliveryDate,
          deliveryTimeSlot: slot ?? _selectedDeliverySlot,
        ),
      );
    }
    notifyListeners();
  }

  void addCustomGiftBox(CustomGiftBox giftBox) {
    _items.add(
      CartItem(
        id: const Uuid().v4(),
        customGiftBox: giftBox,
        quantity: 1,
        greetingMessage: giftBox.cardMessage,
        recipientName: giftBox.cardRecipient,
        deliveryDate: _selectedDeliveryDate,
        deliveryTimeSlot: _selectedDeliverySlot,
      ),
    );
    notifyListeners();
  }

  void updateQuantity(String itemId, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedCoupon = null;
    _discountPercentage = 0.0;
    notifyListeners();
  }

  bool applyCoupon(String code) {
    final clean = code.trim().toUpperCase();
    if (MockData.couponCodes.containsKey(clean)) {
      _appliedCoupon = clean;
      _discountPercentage = MockData.couponCodes[clean]!;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeCoupon() {
    _appliedCoupon = null;
    _discountPercentage = 0.0;
    notifyListeners();
  }

  void setDeliveryDate(DateTime date) {
    _selectedDeliveryDate = date;
    notifyListeners();
  }

  void setDeliverySlot(String slot) {
    _selectedDeliverySlot = slot;
    notifyListeners();
  }

  void setRecipientDetails({
    required String name,
    required String phone,
    required String address,
    String? note,
    String? sender,
    bool isAnon = false,
    String? cardMessage,
  }) {
    _recipientName = name;
    _recipientPhone = phone;
    _deliveryAddress = address;
    if (note != null) _deliveryNote = note;
    if (sender != null) _senderName = sender;
    _isAnonymous = isAnon;
    if (cardMessage != null) _greetingCardMessage = cardMessage;
    notifyListeners();
  }
}
