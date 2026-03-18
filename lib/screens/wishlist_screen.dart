import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_back_button.dart';
import 'profile_screen.dart';
import 'product_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  int _selectedFilterIndex = 0;
  static const List<String> _filters = [
    'All Items',
    'Laptop',
    'Mice',
    'Keyboard',
    'Charger',
    'Laptop Bag',
  ];

  String _normalizeCategory(String value) {
    final v = value.trim().toLowerCase();
    if (v == 'mice') return 'mouse';
    return v;
  }

  String? _selectedCategory() {
    final label = _filters[_selectedFilterIndex];
    if (label == 'All Items') return null;
    if (label == 'Mice') return 'Mouse';
    return label;
  }

  Future<void> _startWishlistSearch(List<Map<String, dynamic>> items) async {
    await showSearch<Map<String, dynamic>?>(
      context: context,
      delegate: _WishlistSearchDelegate(
        items: items,
        onSelect: (item) => _openProductDetails(context, item),
      ),
    );
  }

  Future<void> _openProductDetails(
    BuildContext context,
    Map<String, dynamic> item,
  ) async {
    final productId = (item['id'] ?? '').toString().trim();
    if (productId.isEmpty) return;

    Map<String, dynamic> product = {
      'id': productId,
      'title': (item['title'] ?? '').toString(),
      'imageUrl': (item['image'] ?? '').toString(),
      'imageUrls': [
        (item['image'] ?? '').toString(),
        (item['image'] ?? '').toString(),
        (item['image'] ?? '').toString(),
        (item['image'] ?? '').toString(),
      ],
      'price': (() {
        final raw = (item['price'] ?? '').toString().trim();
        final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
        return double.tryParse(cleaned) ?? 0.0;
      })(),
    };

    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      final data = doc.data();
      if (doc.exists && data != null) {
        product = <String, dynamic>{...data, 'id': doc.id};
      }
    } catch (_) {}

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final wishlistItems = wishlist.items;
    final selectedCategory = _selectedCategory();
    final visibleItems = selectedCategory == null
        ? wishlistItems
        : wishlistItems
              .where(
                (e) =>
                    _normalizeCategory((e['category'] ?? '').toString()) ==
                    _normalizeCategory(selectedCategory),
              )
              .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const Center(child: CustomBackButton()),
        title: Text(
          'Wishlist (${wishlistItems.length})',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _startWishlistSearch(wishlistItems);
            },
            icon: const Icon(Icons.search, color: AppColors.slate900),
          ),
        ],
        bottom: wishlistItems.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_filters.length, (index) {
                        final label = _filters[index];
                        final isSelected = _selectedFilterIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilterIndex = index;
                              });
                            },
                            child: _buildCategoryChip(
                              label,
                              isSelected: isSelected,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: wishlistItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: visibleItems.length,
                      itemBuilder: (context, index) {
                        return _buildWishlistItem(visibleItems[index]);
                      },
                    ),
            ),
            CustomBottomNavBar(
              currentIndex: 3, // Wishlist index
              onTap: (index) {
                if (index == 0) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                } else if (index == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.favorite, color: Colors.grey[400], size: 80),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            'Your wishlist is empty',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Save your favorite laptops here to keep track of them.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.slate900,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'Browse Laptops',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.slate900 : Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.slate900,
        ),
      ),
    );
  }

  Widget _buildWishlistItem(Map<String, dynamic> item) {
    final wishlist = context.read<WishlistProvider>();
    return GestureDetector(
      onTap: () => _openProductDetails(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Heart
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(item['image']),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Details
            if (item['onSale'] == true)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'SALE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            Text(
              item['title'],
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item['specs'],
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  item['price'],
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                if (item['originalPrice'] != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    item['originalPrice'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.slate900,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_cart, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Add to Cart',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      wishlist.removeById((item['id'] ?? '').toString());
                    },
                    icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic> item) onSelect;

  _WishlistSearchDelegate({required this.items, required this.onSelect});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? items
        : items.where((e) {
            final title = (e['title'] ?? '').toString().toLowerCase();
            return title.contains(q);
          }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'Result Not Found',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[200],
            backgroundImage: NetworkImage((item['image'] ?? '').toString()),
          ),
          title: Text(
            (item['title'] ?? '').toString(),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.slate900,
            ),
          ),
          onTap: () {
            close(context, item);
            onSelect(item);
          },
        );
      },
    );
  }
}
