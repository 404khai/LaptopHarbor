import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbor/screens/saved_addresses_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_back_button.dart';
import 'payment_methods_screen.dart';
import 'wishlist_screen.dart';
import 'cart_screen.dart';
import 'search_screen.dart';
import 'my_orders_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const Center(child: CustomBackButton()),
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_rounded, color: AppColors.slate900),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Profile Header
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              image: const DecorationImage(
                                image: AssetImage('images/user.jpeg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditProfileScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: AppColors.slate900,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'John Doe',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Member since Oct 2023',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Stats Row
                    Row(
                      children: [
                        _buildStatCard(
                          icon: Icons.inventory_2,
                          count: '12',
                          label: 'Orders',
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          icon: Icons.favorite,
                          count: '5',
                          label: 'Wishlist',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WishlistScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildStatCard(
                          icon: Icons.rate_review,
                          count: '3',
                          label: 'Reviews',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Menu List
                    _buildMenuItem(
                      icon: Icons.person,
                      title: 'Personal Information',
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      icon: Icons.shopping_bag,
                      title: 'My Orders',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyOrdersScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      icon: Icons.location_on,
                      title: 'Shipping Addresses',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SavedAddressesScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      icon: Icons.credit_card,
                      title: 'Payment Methods',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaymentMethodsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      icon: Icons.security,
                      title: 'Security',
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    const SizedBox(height: 32),

                    // Log Out Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ), // Subtle border
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Log Out',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CustomBottomNavBar(
              currentIndex: 4, // Profile index
              onTap: (index) {
                if (index == 0) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WishlistScreen(),
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

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
            children: [
              Icon(icon, color: AppColors.slate900, size: 24),
              const SizedBox(height: 8),
              Text(
                count,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isHighlighted ? AppColors.slate900 : AppColors.slate900,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isHighlighted
                      ? AppColors.slate900
                      : AppColors.slate900,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isHighlighted ? AppColors.slate900 : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
