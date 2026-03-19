import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbor/screens/saved_addresses_screen.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_back_button.dart';
import 'wishlist_screen.dart';
import 'cart_screen.dart';
import 'search_screen.dart';
import 'my_orders_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'support_screen.dart';
import 'user_reviews_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _statusKey({required dynamic rawStatus, required DateTime createdAt}) {
    final normalized = (rawStatus ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');

    if (normalized == 'cancelled' || normalized == 'canceled') {
      return 'cancelled';
    }
    if (normalized == 'delivered') return 'delivered';
    if (normalized == 'shipped') return 'shipped';
    if (normalized == 'in_transit' || normalized == 'intransit') {
      return 'in_transit';
    }
    if (normalized == 'processing') return 'processing';

    final today = DateTime.now();
    final day0 = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final dayNow = DateTime(today.year, today.month, today.day);
    final diffDays = dayNow.difference(day0).inDays;
    if (diffDays <= 0) return 'processing';
    if (diffDays == 1) return 'shipped';
    if (diffDays == 2) return 'in_transit';
    return 'delivered';
  }

  String _nameFromEmail(String email) {
    final trimmed = email.trim();
    final atIndex = trimmed.indexOf('@');
    final localPart = (atIndex > 0) ? trimmed.substring(0, atIndex) : trimmed;
    if (localPart.isEmpty) return 'User';
    return localPart;
  }

  String _effectiveDisplayName({
    required User? user,
    required Map<String, dynamic>? profile,
  }) {
    if (user == null) return 'Guest';

    final firstName = (profile?['firstName'] as String?)?.trim();
    final lastName = (profile?['lastName'] as String?)?.trim();
    final combined = [firstName, lastName]
        .whereType<String>()
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .join(' ')
        .trim();
    if (combined.isNotEmpty) return combined;

    final profileDisplayName = (profile?['displayName'] as String?)?.trim();
    if (profileDisplayName != null && profileDisplayName.isNotEmpty) {
      return profileDisplayName;
    }

    final authDisplayName = user.displayName?.trim();
    if (authDisplayName != null && authDisplayName.isNotEmpty) {
      return authDisplayName;
    }

    final email = (profile?['email'] as String?)?.trim() ?? user.email?.trim();
    if (email != null && email.isNotEmpty) return _nameFromEmail(email);

    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final profile = authProvider.userProfile;
    final uid = user?.uid;

    final displayName = _effectiveDisplayName(user: user, profile: profile);
    final email = (profile?['email'] as String?) ?? user?.email ?? '';
    final photoUrl =
        (profile?['photoUrl'] as String?)?.trim() ?? user?.photoURL?.trim();

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
                              color: Colors.grey[100],
                            ),
                            child: (photoUrl != null && photoUrl.isNotEmpty)
                                ? ClipOval(
                                    child: Image.network(
                                      photoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.person,
                                                size: 48,
                                                color: AppColors.slate900,
                                              ),
                                            );
                                          },
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 48,
                                    color: user == null
                                        ? Colors.grey
                                        : AppColors.slate900,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                if (user == null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EditProfileScreen(),
                                    ),
                                  );
                                }
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
                      displayName,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email.isNotEmpty ? email : 'Not signed in',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: uid == null
                              ? _buildStatCard(
                                  icon: Icons.inventory_2,
                                  count: '0',
                                  label: 'Active Orders',
                                  onTap: () {},
                                )
                              : StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>
                                >(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .collection('orders')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    final docs =
                                        snapshot.data?.docs ?? const [];
                                    var active = 0;
                                    for (final d in docs) {
                                      final data = d.data();
                                      final createdAtRaw = data['createdAt'];
                                      final createdAt =
                                          createdAtRaw is Timestamp
                                          ? createdAtRaw.toDate()
                                          : DateTime.now();
                                      final key = _statusKey(
                                        rawStatus: data['status'],
                                        createdAt: createdAt,
                                      );
                                      if (key != 'delivered' &&
                                          key != 'cancelled') {
                                        active++;
                                      }
                                    }
                                    return _buildStatCard(
                                      icon: Icons.inventory_2,
                                      count: '$active',
                                      label: 'Active Orders',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const MyOrdersScreen(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: uid == null
                              ? _buildStatCard(
                                  icon: Icons.favorite,
                                  count: '0',
                                  label: 'Wishlist',
                                  onTap: () {},
                                )
                              : StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>
                                >(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .collection('wishlist')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    final count =
                                        snapshot.data?.docs.length ?? 0;
                                    return _buildStatCard(
                                      icon: Icons.favorite,
                                      count: '$count',
                                      label: 'Wishlist',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const WishlistScreen(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: uid == null
                              ? _buildStatCard(
                                  icon: Icons.rate_review,
                                  count: '0',
                                  label: 'Reviews',
                                  onTap: () {},
                                )
                              : StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>
                                >(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .collection('reviews')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    final count =
                                        snapshot.data?.docs.length ?? 0;
                                    return _buildStatCard(
                                      icon: Icons.rate_review,
                                      count: '$count',
                                      label: 'Reviews',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const UserReviewsScreen(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
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
                      icon: Icons.help,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupportScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Log Out Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () async {
                          if (user == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                            return;
                          }
                          await context.read<AuthProvider>().signOut();
                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
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
                            Icon(
                              user == null ? Icons.login : Icons.logout,
                              color: user == null
                                  ? AppColors.slate900
                                  : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user == null ? 'Log In' : 'Log Out',
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
    return GestureDetector(
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
