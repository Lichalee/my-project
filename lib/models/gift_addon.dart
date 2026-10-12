class GiftAddon {
  final String id;
  final String name;
  final String category; // 'Chocolates', 'Candles', 'Treats', 'Plushies', 'Balloons', 'Cards'
  final String description;
  final double price;
  final String imageUrl;
  final String iconEmoji;

  const GiftAddon({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.iconEmoji,
  });
}
