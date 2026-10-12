import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'catalog_screen.dart';
import 'gift_builder_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 800;

    final List<Widget> screens = [
      HomeScreen(onNavigateTab: _onTabTapped),
      const CatalogScreen(),
      GiftBuilderScreen(onCompleted: () => _onTabTapped(3)), // jump to cart on complete
      CartScreen(onExploreMore: () => _onTabTapped(1)),
      ProfileScreen(onSendFlowers: () => _onTabTapped(1)),
    ];

    Widget body = IndexedStack(
      index: _currentIndex,
      children: screens,
    );

    if (isDesktop) {
      body = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: body,
        ),
      );
    }

    return Scaffold(
      // Unified fixed top navigation bar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: _UnifiedHeader(
          currentIndex: _currentIndex,
          onTabSelected: _onTabTapped,
          cartCount: cart.itemCount,
        ),
      ),
      body: body,
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: NavigationBar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onTabTapped,
                  backgroundColor: AppColors.surface,
                  indicatorColor: AppColors.primaryLight.withValues(alpha: 0.15),
                  height: 60,
                  destinations: [
                    const NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home, color: AppColors.primary),
                      label: 'Home',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.local_florist_outlined),
                      selectedIcon: Icon(Icons.local_florist, color: AppColors.primary),
                      label: 'Catalog',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.card_giftcard_outlined),
                      selectedIcon: Icon(Icons.card_giftcard, color: AppColors.primary),
                      label: 'Bespoke Box',
                    ),
                    NavigationDestination(
                      icon: Badge(
                        isLabelVisible: cart.itemCount > 0,
                        label: Text('${cart.itemCount}'),
                        backgroundColor: AppColors.accentRose,
                        child: const Icon(Icons.shopping_bag_outlined),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: cart.itemCount > 0,
                        label: Text('${cart.itemCount}'),
                        backgroundColor: AppColors.accentRose,
                        child: const Icon(Icons.shopping_bag, color: AppColors.primary),
                      ),
                      label: 'Bag',
                    ),
                    const NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person, color: AppColors.primary),
                      label: 'Account',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _UnifiedHeader extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final int cartCount;

  const _UnifiedHeader({
    required this.currentIndex,
    required this.onTabSelected,
    required this.cartCount,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 700;

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 24,
                vertical: 8,
              ),
              child: Row(
                children: [
                  // 1. Logo (Bloom & Ribbon)
                  InkWell(
                    onTap: () => onTabSelected(0),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.local_florist_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                width < 480 ? 'BLOOM' : 'BLOOM & RIBBON',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (!isMobile)
                                Text(
                                  'Bespoke Florals & Gifts',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 2. Navigation Tabs (Home, Catalog, Bespoke Studio) - Expands properly without crushing
                  Expanded(
                    child: Align(
                      alignment: isMobile ? Alignment.centerLeft : Alignment.center,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTabItem(0, 'Home', Icons.home_rounded),
                            const SizedBox(width: 8),
                            _buildTabItem(1, 'Catalog', Icons.local_florist_rounded),
                            const SizedBox(width: 8),
                            _buildTabItem(2, 'Bespoke Studio', Icons.card_giftcard_rounded),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 3. Right-side actions: Search, Cart, Account
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search icon
                      IconButton(
                        tooltip: 'Search Catalog',
                        icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 22),
                        onPressed: () => onTabSelected(1),
                        splashRadius: 20,
                      ),
                      const SizedBox(width: 2),

                      // Shopping Cart icon with badge
                      IconButton(
                        tooltip: 'Shopping Bag',
                        onPressed: () => onTabSelected(3),
                        splashRadius: 20,
                        icon: Badge(
                          isLabelVisible: cartCount > 0,
                          label: Text('$cartCount'),
                          backgroundColor: AppColors.accentRose,
                          child: Icon(
                            currentIndex == 3
                                ? Icons.shopping_bag_rounded
                                : Icons.shopping_bag_outlined,
                            color: currentIndex == 3
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),

                      // Account icon
                      IconButton(
                        tooltip: 'My Account',
                        onPressed: () => onTabSelected(4),
                        splashRadius: 20,
                        icon: Icon(
                          currentIndex == 4
                              ? Icons.person_rounded
                              : Icons.person_outline,
                          color: currentIndex == 4
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.25)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
