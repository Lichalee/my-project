class ProductSizeVariant {
  final String name;
  final String stemDescription;
  final double priceMultiplier;

  const ProductSizeVariant({
    required this.name,
    required this.stemDescription,
    required this.priceMultiplier,
  });
}

class FlowerProduct {
  final String id;
  final String name;
  final String botanicalName;
  final String description;
  final double basePrice;
  final double? originalPrice;
  final String imageUrl;
  final String category; // 'Bouquets', 'Flower Boxes', 'Eternal Blooms', 'Hampers', 'Plants'
  final List<String> occasions; // 'Romance', 'Birthday', 'Anniversary', 'Sympathy', 'Congratulations', 'Get Well Soon'
  final List<String> flowerTypes; // 'Roses', 'Tulips', 'Peonies', 'Lilies', 'Hydrangeas', 'Sunflowers', 'Orchids'
  final double rating;
  final int reviewCount;
  final bool isBestSeller;
  final bool isNewArrival;
  final int fragranceLevel; // 1 to 5
  final int stemCount;
  final int vaseLifeDays;
  final List<String> careInstructions;
  final List<ProductSizeVariant> sizeVariants;
  final bool inStock;

  const FlowerProduct({
    required this.id,
    required this.name,
    required this.botanicalName,
    required this.description,
    required this.basePrice,
    this.originalPrice,
    required this.imageUrl,
    required this.category,
    required this.occasions,
    required this.flowerTypes,
    required this.rating,
    required this.reviewCount,
    this.isBestSeller = false,
    this.isNewArrival = false,
    required this.fragranceLevel,
    required this.stemCount,
    required this.vaseLifeDays,
    required this.careInstructions,
    required this.sizeVariants,
    this.inStock = true,
  });

  double getPriceForSize(String sizeName) {
    final variant = sizeVariants.firstWhere(
      (v) => v.name.toLowerCase() == sizeName.toLowerCase(),
      orElse: () => sizeVariants.first,
    );
    return basePrice * variant.priceMultiplier;
  }
}
