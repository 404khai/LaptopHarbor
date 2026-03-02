import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LaptopHarbor',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
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
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search laptops, accessories...',
                          hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30), // Rounded pill shape
                            borderSide: const BorderSide(color: AppColors.inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: AppColors.inputBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                      ),
                    ),

                    // Categories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildCategoryChip('All', isSelected: true),
                          const SizedBox(width: 12),
                          _buildCategoryChip('Gaming'),
                          const SizedBox(width: 12),
                          _buildCategoryChip('Business'),
                          const SizedBox(width: 12),
                          _buildCategoryChip('Ultra-portable'),
                          const SizedBox(width: 12),
                          _buildCategoryChip('Accessories'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Deals of the Day
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Deals of the Day',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            'View All',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildProductCard(
                            brand: 'RAZER',
                            model: 'Blade 15 Advanced',
                            price: '\$1,999',
                            originalPrice: '\$2,499',
                            discount: '20% OFF',
                            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAveIYKySf9INXZ1FzPrzED5nRqeyR9Y1NPf5RKdGsBLOzHObF6dXikSC3b8xSNSh_YMRdHEioVRRTb3Mv2MJe5gBwT-tqpZh8BZrEovylRWdMAat7VFY2D5hqXcLymMuLa4BkppMhS6TuQqrf0lr8SfkY8oxQcfbNiwWIarayJDfVzYQjcvCWQN3tHUU36L3rPog6ylXq0TzsN4dQWeP1GfwBQA-MNZuBYnw9nY9QYUYfpmOs6sBnQuw8f03SdcmFmZqY86HFgMl0-',
                          ),
                          const SizedBox(width: 16),
                          _buildProductCard(
                            brand: 'DELL',
                            model: 'XPS 13 Plus 9320',
                            price: '\$1,274',
                            originalPrice: '\$1,499',
                            discount: '15% OFF',
                            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDnTSp0Gqh9XU6xxmQ9OrzeHZ89OYezLbK4fRHMbTHTpSuc0l8xvXtE3YQNuuPIyqhFOmz1hyUowRz2F4OvFmeewNExBKSptQlpW_O01mc8ptRYUI3e7zBOc6fkWo0Z2U8mM_jbtosuBYkb12cxgTYHSWfgpAV2svEFUs7d-iLRvbHJ9F_TXjP1ebWwGcv0S7pSplLbx-4PoPRU0wrqJ2_dgMNjjKNtyKNIPYmf81Qf-MmOMGr5uwudOKZrkFEq2bmnseSGRMUgRfWD',
                          ),
                          const SizedBox(width: 16),
                          _buildProductCard(
                            brand: 'APPLE',
                            model: 'MacBook Pro M2',
                            price: '\$2,199',
                            originalPrice: '\$2,399',
                            discount: 'SALE',
                            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAfqjMJCiXoFeMXb0NFMxFuWx3-bwzV_x1gvegSsMrDSnO3F-i56h4IuqAg7jQudv6hTgMX2f7OPATQ0pkdNEYX3_gHmPEmEw3X91v2gkKbAbprT9X06yOeL6cMPTFmPfbvd-G3hsLym-iceDeefbO2-JIEfIyuLKVsY4bCPnpiswbR5DJEQraNbFRRL_YylSq2bmuFruYEzVlesaR5HtyTQZq2LyEUam7WzTZRz9KQm-4GE6Myg09-gjKU8fQ3_aarEwTcTZRuKXTQ',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

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
                          _buildBrandLogo('https://lh3.googleusercontent.com/aida-public/AB6AXuAlz_qVZYWcdwZrBbaIGz-zPP1CK3_Fe-XOpufm4VKYJNQCxsMRzRnrvZkUB7KkZx27so2G_BPi8a3XYJJq-amkzoP08ZxLdh2EpGVgwuItwiL6AqOUcHv8fIKQZAFEHLeWWWY2J44D-iGO50Xj32h2iBMMW-73fv8A-U-IirvgkukG-IDp8QH7jVdHuOnoGF2GMTb2Mn2f_GW6sO8mT8oGYWSwldofxgjSPHwCEyJPXNEejfZf3U5Zw4EQH0tN7UT3XxbVmKHG4tdt'),
                          _buildBrandLogo('https://lh3.googleusercontent.com/aida-public/AB6AXuCrxHSjj1yD8baYVPkOfXXwSvJZzSlukbvR11AzNYDIHcdAeTcloiuTZa0vYAUGtQOLCQ4Qa5qmesMJvMiS8Iefr9udECcVExDCfvwu3nC1iwoND2i3V6ZMMdf8B8T_K1pp3N7D8fOpfX-bOzWEwYiIV9VyaArNyc_UHgdE0sZArBCDETQF2e7v0SoVOD4OlLZnOpjuqXNGZKhRehcjfBvDRqbvo_RD-HQAycCHbuv6OgeArc1tXogtY-Jw04T75XQ9zDJ1bcVeyVNG', size: 40),
                          _buildBrandLogo('https://lh3.googleusercontent.com/aida-public/AB6AXuCf-MWRJnr8wsl98yPhZHoiOzq-MQiEuWOnx7bBY3ZTrzSddd_6IAsYfIiqM2OtJw8OxtgVcDanlRXFVrhj91LrITdaA5HtqmEfeP_HL0A1RxxTr5vRrOL8HbQ3BjnuBHmfxoufM9xMUCKg3ASaFoYcYehay2a7vHOADyA-hcj82NXaJdVLcpAB5pmIzAktmAOvHRH-1OWPyucqqxSIGpRKPs_kb_mg0XI4PsBlPQozzEVF-mJ3hsLeG8ONph8LUtSjnNUvuJOyJN2X'),
                          _buildBrandLogo('https://lh3.googleusercontent.com/aida-public/AB6AXuCMVsfck77BEWKSqzgkVQax_GR_9LvCTL_uY1PkESxIscDljn_Lqun7lAOWeNlq53Asw-IjJbmoO1bgg8sFZOvN9gQ_gqHNv9Yij0xCiO0S9B_ci4nBxu13el-YYprjinQ8djzL_BvHVfxTnEj1QuoGfaVYLNPCXMdgrSXshKuKAykzvuTr3OulLP0Itc7AuENWKyBmlyaKFS5wnEg2tPzhtkBKespjZEqZ8Ond2u_CM0PUbLyfWJWD3T5fYk64hm2k2A5SG8zIDqNd', size: 48),
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
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDRdBtsrt_XkZz7jH5UnbmMaD9BKkz0lwoqk0OAzFNNASkPK0PMEWlvfsD3e8ufBsS8Co3subu5wJNGD32PvXnTfdsLq8AqWlSGl0ukt9h-luRFGvL4iEzFGNHSn_BMht_ZDCgQc5MLepnPqe_Yg5f92qYzuoiCN8BWFP_M6Lnad8JGMqbzOD4sFpN08B-uCj3N3affErmtjB4woQ56bLS25NOqKu9MEGDDfE1QrYK88I-fzlhJBl-wRnKwjuuR244fsH7cXn0YhBAJ'),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.all(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
