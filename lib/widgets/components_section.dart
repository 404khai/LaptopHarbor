import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../screens/product_details_screen.dart';

class ComponentsSection extends StatefulWidget {
  const ComponentsSection({super.key});

  @override
  State<ComponentsSection> createState() => _ComponentsSectionState();
}

class _ComponentsSectionState extends State<ComponentsSection> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'RAM', 'Storage', 'Graphics'];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Corsair Vengeance 32GB',
      'price': '\$129.99',
      'image': 'https://m.media-amazon.com/images/I/61DYLoyNRWL._AC_SL1500_.jpg',
      'rating': 4.8,
      'reviews': 245,
      'isNew': true,
      'description': 'DDR5 5200MHz C40 for Intel Motherboards',
    },
    {
      'name': 'Samsung 980 PRO 2TB',
      'price': '\$169.99',
      'image': 'https://m.media-amazon.com/images/I/71q7+s-n7rL._AC_SL1500_.jpg',
      'rating': 4.9,
      'reviews': 890,
      'isNew': false,
      'description': 'PCIe Gen 4.0 x4, NVMe 1.3c, M.2 Internal SSD',
    },
    {
      'name': 'NVIDIA RTX 4090',
      'price': '\$1,599.00',
      'image': 'https://m.media-amazon.com/images/I/61Zt-8-KxFL._AC_SL1500_.jpg',
      'rating': 4.7,
      'reviews': 120,
      'isNew': true,
      'description': '24GB GDDR6X, The Ultimate GeForce GPU',
    },
    {
      'name': 'Crucial RAM 16GB',
      'price': '\$45.99',
      'image': 'https://m.media-amazon.com/images/I/51H4I1UfR-L._AC_SL1000_.jpg',
      'rating': 4.6,
      'reviews': 560,
      'isNew': false,
      'description': 'DDR4 3200MHz CL22 (or 2933MHz or 2666MHz) Laptop Memory',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Components',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
              Row(
                children: [
                  Text(
                    'See more',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Categories/Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final isSelected = _selectedTabIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.inputBorder,
                    ),
                  ),
                  child: Text(
                    _tabs[index],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.subtext,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),

        // Product Grid
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.70, // Matched with AccessoriesSection
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            return _buildProductCard(_products[index]);
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        final images = <String>[];
        final rawImageUrls = product['imageUrls'] ?? product['images'];
        if (rawImageUrls is List) {
          for (final item in rawImageUrls) {
            if (item is String && item.trim().isNotEmpty) {
              images.add(item.trim());
            }
          }
        }
        final fallbackImage = (product['image'] ?? product['imageUrl'] ?? '')
            .toString()
            .trim();
        if (images.isEmpty && fallbackImage.isNotEmpty) {
          images.add(fallbackImage);
        }
        while (images.length < 4 && images.isNotEmpty) {
          images.add(images.first);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              product: {
                'title': product['name'],
                'price': product['price'],
                'image': product['image'],
                'imageUrls': images.take(4).toList(),
              },
            ),
          ),
        );
      },
      child: Container(
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
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      color: AppColors.slate50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.network(
                          product['image'],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (product['isNew'] == true)
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
                          'New',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 16,
                        color: AppColors.slate900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['price'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Color(0xFFFFC107),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product['rating'].toString(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.subtext,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product['reviews']})',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
