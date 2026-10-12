import 'flower_product.dart';
import 'custom_gift_box.dart';

class CartItem {
  final String id;
  final FlowerProduct? flowerProduct;
  final CustomGiftBox? customGiftBox;
  final String? selectedSizeName; // For flower products: 'Classic', 'Deluxe', 'Grandeur'
  int quantity;
  final String? greetingMessage;
  final String? recipientName;
  final DateTime? deliveryDate;
  final String? deliveryTimeSlot;

  CartItem({
    required this.id,
    this.flowerProduct,
    this.customGiftBox,
    this.selectedSizeName,
    this.quantity = 1,
    this.greetingMessage,
    this.recipientName,
    this.deliveryDate,
    this.deliveryTimeSlot,
  }) : assert(flowerProduct != null || customGiftBox != null);

  bool get isCustomGift => customGiftBox != null;

  String get title {
    if (isCustomGift) {
      return 'Bespoke ${customGiftBox!.packaging.name}';
    }
    return flowerProduct!.name;
  }

  String get subtitle {
    if (isCustomGift) {
      return '${customGiftBox!.palette.name} • ${customGiftBox!.selectedAddons.length} Add-ons';
    }
    return 'Size: ${selectedSizeName ?? "Classic"} (${flowerProduct!.sizeVariants.firstWhere((v) => v.name == (selectedSizeName ?? "Classic"), orElse: () => flowerProduct!.sizeVariants.first).stemDescription})';
  }

  String get imageUrl {
    if (isCustomGift) {
      return 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=500&auto=format&fit=crop&q=80';
    }
    return flowerProduct!.imageUrl;
  }

  double get unitPrice {
    if (isCustomGift) {
      return customGiftBox!.totalPrice;
    }
    return flowerProduct!.getPriceForSize(selectedSizeName ?? 'Classic');
  }

  double get totalPrice => unitPrice * quantity;
}
