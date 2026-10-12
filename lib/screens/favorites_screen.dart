import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/shop_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/flower_card.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback? onExplore;

  const FavoritesScreen({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    final shopProvider = context.watch<ShopProvider>();
    final favorites = shopProvider.favoriteProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist (${favorites.length})'),
        automaticallyImplyLeading: false,
      ),
      body: favorites.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.accentRoseLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.accentRose),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Saved Favorites Yet',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the heart icon on any bouquet to save it to your wishlist for later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => onExplore?.call(),
                      icon: const Icon(Icons.explore_outlined, size: 18),
                      label: const Text('Explore Arrangements'),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favorites.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final product = favorites[index];
                return FlowerCard(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
