import 'gift_addon.dart';

enum PackagingType {
  velvetBox(
    id: 'velvet_box',
    name: 'Royal Velvet Cylinder Box',
    description: 'Plush velvet finish with gold foil monogram',
    basePrice: 18.0,
    iconEmoji: '🎁',
  ),
  ceramicVase(
    id: 'ceramic_vase',
    name: 'Artisan Matte Ceramic Vase',
    description: 'Handcrafted Scandinavian ribbed vase',
    basePrice: 24.0,
    iconEmoji: '🏺',
  ),
  kraftWrap(
    id: 'kraft_wrap',
    name: 'Parisian French Kraft Wrap',
    description: 'Layered eco-kraft paper tied with silk ribbon',
    basePrice: 10.0,
    iconEmoji: '💐',
  ),
  acrylicDisplay(
    id: 'acrylic_box',
    name: 'Luxury Crystal Clear Acrylic Box',
    description: 'Contemporary transparent showcase with pull-out drawer',
    basePrice: 28.0,
    iconEmoji: '💎',
  ),
  wovenBasket(
    id: 'woven_basket',
    name: 'Rustic Willow Picnic Hamper',
    description: 'Natural hand-braided basket with linen lining',
    basePrice: 22.0,
    iconEmoji: '🧺',
  );

  final String id;
  final String name;
  final String description;
  final double basePrice;
  final String iconEmoji;

  const PackagingType({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.iconEmoji,
  });
}

enum FloralPalette {
  crimsonPassion(
    id: 'crimson',
    name: 'Crimson Passion',
    description: 'Red Ecuadorian Roses, Dark Calla Lilies & Eucalyptus',
    colorHex: 0xFF9E1B32,
    price: 45.0,
  ),
  pastelDream(
    id: 'pastel',
    name: 'Pastel Dreamscape',
    description: 'Pink Peonies, Lilac Hydrangeas, White Lisianthus & Baby\'s Breath',
    colorHex: 0xFFF2B5D4,
    price: 48.0,
  ),
  pureSerenity(
    id: 'white',
    name: 'Pure Serenity',
    description: 'Casablanca Lilies, White Garden Roses & Olive Foliage',
    colorHex: 0xFFEAEAEA,
    price: 42.0,
  ),
  goldenSunrise(
    id: 'gold',
    name: 'Golden Sunrise',
    description: 'Sunflowers, Yellow Spray Roses, Solidago & Chamomile',
    colorHex: 0xFFF7C844,
    price: 38.0,
  ),
  lavenderMist(
    id: 'lavender',
    name: 'Lavender Whisper',
    description: 'Purple Orchids, French Lavender & Blue Eryngium Thistle',
    colorHex: 0xFFB19CD9,
    price: 46.0,
  );

  final String id;
  final String name;
  final String description;
  final int colorHex;
  final double price;

  const FloralPalette({
    required this.id,
    required this.name,
    required this.description,
    required this.colorHex,
    required this.price,
  });
}

class CustomGiftBox {
  final String id;
  final PackagingType packaging;
  final FloralPalette palette;
  final List<GiftAddon> selectedAddons;
  final String ribbonText;
  final String cardRecipient;
  final String cardMessage;
  final String cardSender;
  final String cardDesign; // 'Classic Floral', 'Modern Minimal', 'Gold Foil Vintage'
  final bool hasWaxSeal;
  final String waxSealColor; // 'Burgundy Red', 'Antique Gold', 'Forest Green'

  CustomGiftBox({
    required this.id,
    required this.packaging,
    required this.palette,
    required this.selectedAddons,
    this.ribbonText = '',
    this.cardRecipient = '',
    this.cardMessage = '',
    this.cardSender = '',
    this.cardDesign = 'Classic Floral',
    this.hasWaxSeal = true,
    this.waxSealColor = 'Antique Gold',
  });

  double get totalPrice {
    double total = packaging.basePrice + palette.price;
    for (var addon in selectedAddons) {
      total += addon.price;
    }
    if (hasWaxSeal) total += 3.50;
    if (ribbonText.trim().isNotEmpty) total += 2.00;
    return total;
  }
}
