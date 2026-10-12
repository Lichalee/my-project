import 'package:flutter/material.dart';
import '../models/flower_product.dart';
import '../data/mock_data.dart';

enum SortOption {
  featured('Featured'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  highestRated('Highest Rated'),
  stemCount('Stem Count');

  final String label;
  const SortOption(this.label);
}

class ShopProvider extends ChangeNotifier {
  List<FlowerProduct> _products = [];
  String _selectedCategory = 'All Flowers';
  String? _selectedOccasion;
  String _searchQuery = '';
  SortOption _sortOption = SortOption.featured;
  final Set<String> _favoriteProductIds = {'fl_01', 'fl_02'};

  ShopProvider() {
    _products = List.from(MockData.flowerProducts);
  }

  List<FlowerProduct> get allProducts => _products;
  String get selectedCategory => _selectedCategory;
  String? get selectedOccasion => _selectedOccasion;
  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;
  Set<String> get favoriteProductIds => _favoriteProductIds;

  List<FlowerProduct> get favoriteProducts {
    return _products.where((p) => _favoriteProductIds.contains(p.id)).toList();
  }

  List<FlowerProduct> get bestSellers {
    return _products.where((p) => p.isBestSeller).toList();
  }

  List<FlowerProduct> get newArrivals {
    return _products.where((p) => p.isNewArrival).toList();
  }

  List<FlowerProduct> get filteredProducts {
    List<FlowerProduct> list = _products;

    // Filter by Category
    if (_selectedCategory != 'All Flowers') {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }

    // Filter by Occasion
    if (_selectedOccasion != null && _selectedOccasion!.isNotEmpty) {
      list = list.where((p) => p.occasions.contains(_selectedOccasion)).toList();
    }

    // Filter by Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.botanicalName.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.flowerTypes.any((f) => f.toLowerCase().contains(q));
      }).toList();
    }

    // Sort
    switch (_sortOption) {
      case SortOption.priceLowToHigh:
        list.sort((a, b) => a.basePrice.compareTo(b.basePrice));
        break;
      case SortOption.priceHighToLow:
        list.sort((a, b) => b.basePrice.compareTo(a.basePrice));
        break;
      case SortOption.highestRated:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.stemCount:
        list.sort((a, b) => b.stemCount.compareTo(a.stemCount));
        break;
      case SortOption.featured:
        // keep default order
        break;
    }

    return list;
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _selectedOccasion = null; // reset occasion when picking direct category
    notifyListeners();
  }

  void selectOccasion(String? occasion) {
    _selectedOccasion = occasion;
    _selectedCategory = 'All Flowers'; // reset category filter
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    if (_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    notifyListeners();
  }

  bool isFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }

  FlowerProduct? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
