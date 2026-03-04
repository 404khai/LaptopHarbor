import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_back_button.dart';
import 'profile_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // Mock data for wishlist items
  final List<Map<String, dynamic>> _wishlistItems = [
    {
      'id': '1',
      'title': 'MacBook Pro 14" - M3 Chip',
      'specs': 'Space Gray | 512GB SSD',
      'price': '\$1,999.00',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBt2jj16meEr_EJJ2c-urSC0jTL1FY-fF6ZF-viOHe3K-g2fCGUYgSKC9ym1_g7teczS3t0kLyuAJxiqtiKW-aJJk8C_6jOK-0oksv-rsK3m-EnvCweePMONffur_yjYaXlQb21Tpu9A-ruyYnlcY12VV4jcdCKz2ZhHTzC06PBQyhDwA0Bu3Ib-4y67MAhuA85QDPxs8ghqUBWT4yHAypfh0Kalvs9Yo9jxNxHG6uF3MeHD3_xvoHa6c_3ienWdz22OxFy4VwN-kn9',
      'onSale': false,
    },
    {
      'id': '2',
      'title': 'Dell XPS 13 Plus',
      'specs': 'Platinum | Intel Core i7',
      'price': '\$1,399.00',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDnTSp0Gqh9XU6xxmQ9OrzeHZ89OYezLbK4fRHMbTHTpSuc0l8xvXtE3YQNuuPIyqhFOmz1hyUowRz2F4OvFmeewNExBKSptQlpW_O01mc8ptRYUI3e7zBOc6fkWo0Z2U8mM_jbtosuBYkb12cxgTYHSWfgpAV2svEFUs7d-iLRvbHJ9F_TXjP1ebWwGcv0S7pSplLbx-4PoPRU0wrqJ2_dgMNjjKNtyKNIPYmf81Qf-MmOMGr5uwudOKZrkFEq2bmnseSGRMUgRfWD',
      'onSale': false,
    },
    {
      'id': '3',
      'title': 'Razer Blade 15',
      'specs': 'Black | RTX 4070',
      'price': '\$2,249.00',
      'originalPrice': '\$2,499.00',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAveIYKySf9INXZ1FzPrzED5nRqeyR9Y1NPf5RKdGsBLOzHObF6dXikSC3b8xSNSh_YMRdHEioVRRTb3Mv2MJe5gBwT-tqpZh8BZrEovylRWdMAat7VFY2D5hqXcLymMuLa4BkppMhS6TuQqrf0lr8SfkY8oxQcfbNiwWIarayJDfVzYQjcvCWQN3tHUU36L3rPog6ylXq0TzsN4dQWeP1GfwBQA-MNZuBYnw9nY9QYUYfpmOs6sBnQuw8f03SdcmFmZqY86HFgMl0-',
      'onSale': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const Center(child: CustomBackButton()),
        title: Text(
          'Wishlist',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.slate900),
          ),
        ],
        bottom: _wishlistItems.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      _buildTab('All Items (${_wishlistItems.length})', true),
                      const SizedBox(width: 24),
                      _buildTab('Available', false),
                      const SizedBox(width: 24),
                      _buildTab('On Sale', false),
                    ],
                  ),
                ),
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _wishlistItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _wishlistItems.length,
                      itemBuilder: (context, index) {
                        return _buildWishlistItem(_wishlistItems[index]);
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

  Widget _buildTab(String title, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.slate900 : Colors.grey[500],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: isSelected ? 40 : 0, // Simplified indicator width
          color: isSelected ? AppColors.primary : Colors.transparent,
        ),
      ],
    );
  }

  Widget _buildWishlistItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                color: AppColors.primary.withOpacity(0.2),
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
                    // Find the index of the item to remove
                    final index = _wishlistItems.indexOf(item);
                    if (index != -1) {
                      setState(() {
                        _wishlistItems.removeAt(index);
                      });
                    }
                  },
                  icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
