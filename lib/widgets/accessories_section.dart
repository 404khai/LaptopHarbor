import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../screens/product_details_screen.dart';

class AccessoriesSection extends StatefulWidget {
  const AccessoriesSection({super.key});

  @override
  State<AccessoriesSection> createState() => _AccessoriesSectionState();
}

class _AccessoriesSectionState extends State<AccessoriesSection> {
  final List<String> _tabs = ['All', 'Mice', 'Keyboards', 'Headsets'];
  int _selectedTabIndex = 0;

  final List<Map<String, dynamic>> _products = [
    {
      'brand': 'Logitech MX Master 3S',
      'rating': 4.8,
      'price': '\$99.99',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAzZlx_JzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZzJzZz', // Placeholder link, using a generic one for now
      'stock': 'IN STOCK',
    },
    {
      'brand': 'Keychron Q1 Pro',
      'rating': 4.9,
      'price': '\$199.00',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDdQGu2MLxiCv5niGdOvulHpZUQYjghekoAB7_gnKDcHA53MB6E_l5gNsEUbsJTpMKI-qpkRDOA3ByJfE-Ye5a1bnI0efCr2ZthQo2-UOGlIplQJDR4Ro04vEHohYJCdg6MiuaZtwHZM-wBg3gSMn3Ncu-Htk1qQH4gh3pDXD9dPcRfHcW9ldLTUV6FEjWXxtZMYPs23q1tADI2mMuwZfEUpz_LBsnJ0kAVHaGF_WZvyY0PZB5Qwd4OxTg2i-Q5hhLTV3gED-MFVdIS',
      'stock': 'IN STOCK',
    },
    {
      'brand': 'Sony WH-1000XM5',
      'rating': 4.7,
      'price': '\$348.00',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDoiqvihi8zSXS0rX1I5uxfYpMRV7ch7DHhuED8vQpD62saqnhhW2Wc5ptdhFzpM4nlztTNtHWz4WOVMSSYIZs7vBd97AIqON6_mImhX0LRV5gUH_cJtAFRJTvoEjJWHAKT9zDq69qTtfBIC8q5gMW2mgE9e1z_qSaCnmpNFIQESIX3GP5bDfq5siuHtm0qH5oY3u0N2l-uFCVV26C8oa76vqieQmkeHY8aCZMIvDGs6M3EisCRgD9c2LsInEYcM574I6X74nCFe3mY',
      'stock': 'IN STOCK',
    },
    {
      'brand': 'Dell 27" 4K Monitor',
      'rating': 4.6,
      'price': '\$449.99',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBCMHK6QD_9JJxtISBzUHendBlwylUI2KYB7odTWOFB0XIqQeu7ULw56991EllrDAl-DZIlzz-wsEcRT1g2WRH4diJt_1FpxfcyWobQq70qyzyLbIWB9BRraoWWsSAZRzDfyvGlhC7WWp9Ao6nP3O4tomhE8TchGd701zmv8S8FZ6VOeBv_FCdiVqaz3kvdQ72d-Osdjcq39kW6vumsWgBtd8-osSLrPKX-qDTAYkviz_FQPAlX5xc-rI2LSUwSsBcg9aPQGfk59Cux',
      'stock': 'IN STOCK',
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
                'Accessories',
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

        // Tabs
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
                  margin: const EdgeInsets.only(right: 24.0),
                  padding: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Text(
                    _tabs[index],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.slate900 : Colors.grey[400],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),

        // Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.70,
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              return _buildProductCard(product);
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              product: {
                'title': product['brand'],
                'price': product['price'],
                'image': product['image'],
                'stock': product['stock'] ?? 'IN STOCK',
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      width: double.infinity,
                      color: AppColors.slate50,
                      child: Image.network(
                        product['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border, size: 16, color: AppColors.slate900),
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['brand'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppColors.slate900),
                      const SizedBox(width: 4),
                      Text(
                        '${product['rating']}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product['price'],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.slate900,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
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
