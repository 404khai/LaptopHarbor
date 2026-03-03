import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class LaptopsSection extends StatefulWidget {
  const LaptopsSection({super.key});

  @override
  State<LaptopsSection> createState() => _LaptopsSectionState();
}

class _LaptopsSectionState extends State<LaptopsSection> {
  final List<String> _tabs = ['All', 'Gaming', 'Ultrabooks', 'Workstation'];
  int _selectedTabIndex = 0;

  final List<Map<String, dynamic>> _laptops = [
    {
      'brand': 'MacBook Pro M3',
      'rating': 4.9,
      'price': '\$1,599.00',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDlTmJfoewKdiDVkNFs1GlPFV4WfErPhGDK670DxPDzF40qOB-30uI81qvZrjGuy_K4OB2auSiAb2oynY4FsWJCwoFaUCNAIzKV_h0SIMS52bpByd0wTgFgvmidsH00vBoBjOaQ2p50hN9iH1xdm5fKa36A66d_Dqkj4v-dF5Rg33kKSMTNAp4_l3bo5EfikPSXfivfnmuxgLt0UEDs3f_vCfs3IlY9YGWs6-mS6QMMtQIWEM2ttGsTXDl3ZCmehBpakyk-2HpusB4g',
    },
    {
      'brand': 'Dell XPS 15',
      'rating': 4.7,
      'price': '\$1,399.00',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDWicXjiNoU7pZdNZ9WpO8VZLZPnteX_zTRedS0l4UuN3kuu-S-VE4_yvK5aLDkosSvyfePA5rgq8mnYvENwz2_bHxt2xkcVLxgVLJy1_Vv3jvYi4wn2y83GN2TWXxpWNHuHzMlaznQi0lqleByVFtzU6hJF7UzOJa31pwN7XBYkAP38bvZYC2JR-lqZ8XFfXOdUypS4WvvHbf_Gif48Tgg1gIPvg_qom7N2qrB0Z7-F-cFmuClIx2JLU0S1XIWGZE7TqBQOBpKkPNe',
    },
    {
      'brand': 'Razer Blade 16',
      'rating': 4.8,
      'price': '\$2,999.99',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDJr2YPCqzrOuhSY_hV3h6VPy4-IROCQZ1c-047sYO1lRhhYAG1gDNQsggXWopfcNrzs-tyBSx8UGx69xRUmP4xBWHguSRV9WcpRL_KEHlRYfHiIVI-T8g2meI7NMqV_fkPbIga_f50mMmcFEp9WcXmxghNWSzsJZQ549cCQ7ffSpYrP--i7BXWgfwoScsKbfyk-NyDU-l-ADITM20V06XZCpn1IH7paGkqJLsHfdRzDp7Fzjotc9YQYcmHYYJVxGAuP8IhMcejbNL0',
    },
    {
      'brand': 'HP Spectre x360',
      'rating': 4.6,
      'price': '\$1,249.50',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAKw6cGEIv4opeRFfXRPGQlCieh_I82XWQFFRU3-EaRwXTOM9-Jq9yipWBAlK8qmGnpvZMc5Lsrs8Hgup-0z_NrCuP34_s7sNV5c4opaypN3rhPuGLn6LXdPyxqdJ4P_Ud2is82r7gOm5cbxUs7D0EMdbMMtor_8zjknxrtPNa1Q6H8PfkWoH14xRKnAh9L28WE-0bhIbEO5CMMGFOkVr-i2iqTVU_QoUYbNPXFcIr9QJkPfjr4hT-lDHYSVeS6Nw9KGfXQqvvWKI9L',
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
                'Laptops',
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
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Text(
                    _tabs[index],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
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
              childAspectRatio: 0.70, // Slightly taller to fit all content
            ),
            itemCount: _laptops.length,
            itemBuilder: (context, index) {
              final laptop = _laptops[index];
              return _buildLaptopCard(laptop);
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLaptopCard(Map<String, dynamic> laptop) {
    return Container(
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: AppColors.slate50,
                    child: Image.network(
                      laptop['image'],
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
                    child: const Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: AppColors.slate900,
                    ),
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
                  laptop['brand'],
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
                      '${laptop['rating']}',
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
                      laptop['price'],
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
                      child: const Icon(
                        Icons.add_shopping_cart,
                        size: 16,
                        color: Colors.white,
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
}
