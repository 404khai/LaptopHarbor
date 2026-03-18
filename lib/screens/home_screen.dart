import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/techspecs_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';
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
  List<Map<String, String>> _brandLogos = [];
  int _selectedCategoryIndex = 0;
  static const List<String> _homeCategoryChips = [
    'All',
    'Laptop',
    'Mouse',
    'Keyboard',
    'Charger',
    'Bag',
  ];

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
    try {
      final service = TechSpecsService();
      final brandLogos = await service.getBrandLogos();

      if (!mounted) return;
      setState(() {
        _brandLogos = brandLogos;
      });
    } catch (e) {
      return;
    }
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
                    // Categories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(_homeCategoryChips.length, (
                          index,
                        ) {
                          final label = _homeCategoryChips[index];
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
                        }),
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

                    if (_shouldShowSection('Laptop')) ...[
                      const FirestoreProductSection(
                        title: 'Laptops',
                        category: 'Laptop',
                        randomize: true,
                      ),
                      const SizedBox(height: 32),
                    ],
                    if (_shouldShowSection('Mouse')) ...[
                      const FirestoreProductSection(
                        title: 'Mice',
                        category: 'Mouse',
                        randomize: true,
                      ),
                      const SizedBox(height: 32),
                    ],
                    if (_shouldShowSection('Keyboard')) ...[
                      const FirestoreProductSection(
                        title: 'Keyboards',
                        category: 'Keyboard',
                        randomize: true,
                      ),
                      const SizedBox(height: 32),
                    ],
                    if (_shouldShowSection('Laptop Bag')) ...[
                      const FirestoreProductSection(
                        title: 'Laptop Bags',
                        category: 'Laptop Bag',
                        randomize: true,
                      ),
                      const SizedBox(height: 32),
                    ],
                    if (_shouldShowSection('Charger')) ...[
                      const FirestoreProductSection(
                        title: 'Chargers',
                        category: 'Charger',
                        randomize: true,
                      ),
                      const SizedBox(height: 32),
                    ],
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

  String? _selectedFirestoreCategory() {
    final label = _homeCategoryChips[_selectedCategoryIndex];
    if (label == 'All') return null;
    if (label == 'Bag') return 'Laptop Bag';
    return label;
  }

  bool _shouldShowSection(String category) {
    final selected = _selectedFirestoreCategory();
    return selected == null || selected == category;
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
