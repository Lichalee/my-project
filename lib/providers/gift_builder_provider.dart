import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/custom_gift_box.dart';
import '../models/gift_addon.dart';
import '../data/mock_data.dart';

class GiftBuilderProvider extends ChangeNotifier {
  int _currentStep = 0;

  // Selected Customization Options
  PackagingType _selectedPackaging = PackagingType.velvetBox;
  FloralPalette _selectedPalette = FloralPalette.pastelDream;
  final List<GiftAddon> _selectedAddons = [
    MockData.giftAddons[0], // Neuhaus Truffles by default
  ];

  String _ribbonText = 'Forever Yours';
  String _cardRecipient = 'My Dearest';
  String _cardMessage = 'May your day bloom as beautifully and brightly as these fresh flowers. With all my love.';
  String _cardSender = 'Julian';
  String _cardDesign = 'Classic Floral';
  bool _hasWaxSeal = true;
  String _waxSealColor = 'Antique Gold';

  final List<String> availableCardDesigns = [
    'Classic Floral',
    'Modern Minimalist',
    'Vintage Gold Leaf',
    'Botanical Botanical Sage',
  ];

  final List<String> availableWaxSeals = [
    'Antique Gold',
    'Burgundy Red',
    'Forest Sage',
    'Champagne Pearl',
  ];

  int get currentStep => _currentStep;
  PackagingType get selectedPackaging => _selectedPackaging;
  FloralPalette get selectedPalette => _selectedPalette;
  List<GiftAddon> get selectedAddons => List.unmodifiable(_selectedAddons);
  String get ribbonText => _ribbonText;
  String get cardRecipient => _cardRecipient;
  String get cardMessage => _cardMessage;
  String get cardSender => _cardSender;
  String get cardDesign => _cardDesign;
  bool get hasWaxSeal => _hasWaxSeal;
  String get waxSealColor => _waxSealColor;

  double get totalPrice {
    double total = _selectedPackaging.basePrice + _selectedPalette.price;
    for (var addon in _selectedAddons) {
      total += addon.price;
    }
    if (_hasWaxSeal) total += 3.50;
    if (_ribbonText.trim().isNotEmpty) total += 2.00;
    return total;
  }

  void setStep(int step) {
    if (step >= 0 && step <= 3) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void selectPackaging(PackagingType packaging) {
    _selectedPackaging = packaging;
    notifyListeners();
  }

  void selectPalette(FloralPalette palette) {
    _selectedPalette = palette;
    notifyListeners();
  }

  void toggleAddon(GiftAddon addon) {
    final exists = _selectedAddons.any((a) => a.id == addon.id);
    if (exists) {
      _selectedAddons.removeWhere((a) => a.id == addon.id);
    } else {
      _selectedAddons.add(addon);
    }
    notifyListeners();
  }

  bool isAddonSelected(String addonId) {
    return _selectedAddons.any((a) => a.id == addonId);
  }

  void updateRibbonText(String text) {
    _ribbonText = text;
    notifyListeners();
  }

  void updateCardDetails({
    String? recipient,
    String? message,
    String? sender,
    String? design,
    bool? waxSeal,
    String? sealColor,
  }) {
    if (recipient != null) _cardRecipient = recipient;
    if (message != null) _cardMessage = message;
    if (sender != null) _cardSender = sender;
    if (design != null) _cardDesign = design;
    if (waxSeal != null) _hasWaxSeal = waxSeal;
    if (sealColor != null) _waxSealColor = sealColor;
    notifyListeners();
  }

  CustomGiftBox buildGiftBox() {
    return CustomGiftBox(
      id: const Uuid().v4(),
      packaging: _selectedPackaging,
      palette: _selectedPalette,
      selectedAddons: List.from(_selectedAddons),
      ribbonText: _ribbonText,
      cardRecipient: _cardRecipient,
      cardMessage: _cardMessage,
      cardSender: _cardSender,
      cardDesign: _cardDesign,
      hasWaxSeal: _hasWaxSeal,
      waxSealColor: _waxSealColor,
    );
  }

  void reset() {
    _currentStep = 0;
    _selectedPackaging = PackagingType.velvetBox;
    _selectedPalette = FloralPalette.pastelDream;
    _selectedAddons.clear();
    _selectedAddons.add(MockData.giftAddons[0]);
    _ribbonText = 'Forever Yours';
    _cardRecipient = 'My Dearest';
    _cardMessage = 'May your day bloom as beautifully and brightly as these fresh flowers. With all my love.';
    _cardSender = 'Julian';
    _cardDesign = 'Classic Floral';
    _hasWaxSeal = true;
    _waxSealColor = 'Antique Gold';
    notifyListeners();
  }
}
