import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';
import '../services/techspecs_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/components_section.dart';
import '../widgets/firestore_product_section.dart';
import 'cart_screen.dart';
import 'search_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isHomeLoading = false;
  String? _homeError;
  List<Product> _deals = [];
  List<Map<String, String>> _brandLogos = [];
  List<String> _categories = [];
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeData();
    });
  }

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const SearchScreen()));
    } else if (index == 2) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const CartScreen()));
    } else if (index == 3) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const WishlistScreen()));
    } else if (index == 4) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _isHomeLoading = true;
      _homeError = null;
    });

    try {
      final service = TechSpecsService();
      final categories = await service.getCategories(size: 10);
      final brandLogos = await service.getBrandLogos();
      final deals = await service.searchLaptops('laptop');
      final enrichedDeals = <Product>[];
      for (final product in deals.take(10)) {
        var imageUrl = product.imageUrl;
        if (imageUrl.isEmpty &&
            product.id.isNotEmpty &&
            enrichedDeals.length < 3) {
          try {
            final images = await service.getProductImages(product.id);
            if (images.isNotEmpty) imageUrl = images.first;
          } catch (_) {}
        }

        if (imageUrl == product.imageUrl) {
          enrichedDeals.add(product);
        } else {
          enrichedDeals.add(
            Product(
              id: product.id,
              brand: product.brand,
              model: product.model,
              imageUrl: imageUrl,
              price: product.price,
              originalPrice: product.originalPrice,
              description: product.description,
              specifications: product.specifications,
              category: product.category,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _categories = categories.isNotEmpty ? categories : ['Laptops'];
          _brandLogos = brandLogos;
          _deals = enrichedDeals;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _homeError = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isHomeLoading = false;
        });
      }
    }
  }

  String _formatPrice(double value) {
    if (value <= 0) return '\$--';
    if (value >= 1000) return '\$${value.toStringAsFixed(0)}';
    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'images/logo2.png',
                    height: 40, // Adjust height as needed to match design
                    fit: BoxFit.contain,
                  ),
                  Text(
                    'LaptopHarbor',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100], // Secondary-bg
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      color: AppColors.text,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_homeError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _homeError!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    // Categories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(
                          (_categories.isNotEmpty ? _categories : ['All'])
                              .take(8)
                              .length,
                          (index) {
                            final label = (_categories.isNotEmpty
                                ? _categories
                                : ['All'])[index];
                            final isSelected = _selectedCategoryIndex == index;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryIndex = index;
                                  });
                                },
                                child: _buildCategoryChip(
                                  label,
                                  isSelected: isSelected,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Top Brands
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Top Brands',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_brandLogos.isNotEmpty)
                            ..._brandLogos.take(4).toList().asMap().entries.map(
                              (entry) {
                                final index = entry.key;
                                final item = entry.value;
                                final url = item['logoUrl'];
                                if (url == null || url.isEmpty) {
                                  return const SizedBox(width: 72, height: 72);
                                }
                                return _buildBrandLogo(
                                  url,
                                  size: index == 1
                                      ? 40
                                      : (index == 3 ? 48 : 32),
                                );
                              },
                            )
                          else ...[
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'images/lenovo.png',
                                  width: 32,
                                  height: 32,
                                  color: Colors.black.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'images/apple.png',
                                  width: 40,
                                  height: 40,
                                  color: Colors.black.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'images/dell.png',
                                  width: 32,
                                  height: 32,
                                  color: Colors.black.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'images/razer.png',
                                  width: 48,
                                  height: 48,
                                  color: Colors.black.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Featured Section (Editor's Choice)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color(0xFF0F172A),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDRdBtsrt_XkZz7jH5UnbmMaD9BKkz0lwoqk0OAzFNNASkPK0PMEWlvfsD3e8ufBsS8Co3subu5wJNGD32PvXnTfdsLq8AqWlSGl0ukt9h-luRFGvL4iEzFGNHSn_BMht_ZDCgQc5MLepnPqe_Yg5f92qYzuoiCN8BWFP_M6Lnad8JGMqbzOD4sFpN08B-uCj3N3affErmtjB4woQ56bLS25NOqKu9MEGDDfE1QrYK88I-fzlhJBl-wRnKwjuuR244fsH7cXn0YhBAJ',
                            ),
                            fit: BoxFit.cover,
                            opacity: 0.6,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "EDITOR'S CHOICE",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 200,
                                child: Text(
                                  'The Future of Workstations',
                                  style: GoogleFonts.inter(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Shop Now',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Laptops Section
                    const FirestoreProductSection(
                      title: 'Laptops',
                      category: 'Laptop',
                    ),
                    const SizedBox(height: 32),

                    const FirestoreProductSection(
                      title: 'Mice',
                      category: 'Mouse',
                    ),
                    const SizedBox(height: 32),

                    const FirestoreProductSection(
                      title: 'Keyboards',
                      category: 'Keyboard',
                    ),
                    const SizedBox(height: 32),

                    const FirestoreProductSection(
                      title: 'Laptop Bags',
                      category: 'Laptop Bag',
                    ),
                    const SizedBox(height: 32),

                    const FirestoreProductSection(
                      title: 'Chargers',
                      category: 'Charger',
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0F172A) : Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.text,
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String brand,
    required String model,
    required String price,
    required String originalPrice,
    required String discount,
    required String imageUrl,
  }) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
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
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    discount,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  model,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      originalPrice,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[400],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandLogo(String imageUrl, {double size = 32}) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Image.network(
          imageUrl,
          width: size,
          height: size,
          color: Colors.black.withValues(alpha: 0.7),
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error_outline, size: 24, color: Colors.grey),
        ),
      ),
    );
  }
}
