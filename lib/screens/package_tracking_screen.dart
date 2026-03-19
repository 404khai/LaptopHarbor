import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';

class PackageTrackingScreen extends StatelessWidget {
  final String orderId;

  const PackageTrackingScreen({super.key, required this.orderId});

  String _statusFromCreatedAt(DateTime createdAt) {
    final today = DateTime.now();
    final day0 = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final dayNow = DateTime(today.year, today.month, today.day);
    final diffDays = dayNow.difference(day0).inDays;
    if (diffDays <= 0) return 'processing';
    if (diffDays == 1) return 'shipped';
    if (diffDays == 2) return 'in_transit';
    return 'delivered';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'processing':
        return 'PROCESSING';
      case 'shipped':
        return 'SHIPPED';
      case 'in_transit':
        return 'IN TRANSIT';
      case 'delivered':
        return 'DELIVERED';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const Center(child: CustomBackButton()),
          centerTitle: true,
          title: Text(
            'Tracking',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Text(
              'Please sign in to track orders.',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.slate900,
              ),
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 4,
          onTap: (index) {},
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('orders')
          .doc(orderId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final orderNumber = (data?['orderNumber'] ?? '').toString().trim();
        final createdAtTs = data?['createdAt'];
        final createdAt = (createdAtTs is Timestamp)
            ? createdAtTs.toDate()
            : DateTime.now();
        final status = _statusFromCreatedAt(createdAt);
        if (data != null && (data['status'] ?? '') != status) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('orders')
              .doc(orderId)
              .set(<String, dynamic>{
                'status': status,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
        }

        final placedDone = true;
        final shippedDone =
            status == 'shipped' ||
            status == 'in_transit' ||
            status == 'delivered';
        final transitDone = status == 'in_transit' || status == 'delivered';
        final arrivedDone = status == 'delivered';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const Center(child: CustomBackButton()),
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  orderNumber.isEmpty ? 'Order' : 'Order $orderNumber',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                Text(
                  _statusLabel(status),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.info_outline, color: AppColors.slate900),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 24.0,
                ),
                child: Row(
                  children: [
                    _buildStatusStep('PLACED', placedDone, placedDone),
                    Expanded(child: _buildConnector(shippedDone)),
                    _buildStatusStep('SHIPPED', shippedDone, shippedDone),
                    Expanded(child: _buildConnector(transitDone)),
                    _buildStatusStep(
                      'TRANSIT',
                      transitDone,
                      transitDone,
                      icon: Icons.local_shipping,
                    ),
                    Expanded(child: _buildConnector(arrivedDone)),
                    _buildStatusStep(
                      'ARRIVED',
                      arrivedDone,
                      arrivedDone,
                      icon: Icons.inventory_2,
                    ),
                  ],
                ),
              ),

              // Map and Details Area
              Expanded(
                child: Stack(
                  children: [
                    // Map Placeholder
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuCVgrShSJ6I29ydoR1Y1WBco-bAu20EfxKJRkgRzMyHuPN9kE3bFiEDpbaFhv5JzFJK5C5iUFgsfapZ1bF30oFyZy6VGZy43RNOLqLG2aAuve14r9kBZgh3L1w9lBF6de0Z0lJuguinhyCe_qk8QgHYtFWKXcBqqjcTUmp2NLgQVqYTnSCnYHHcwsdAwMil5pKoZYZASUD1-E-B41j0PekPnwEquu2Wi1c2EPXBoEBFA6TNcLqxaAVhX8yXGjL65vZ4FIdcpFfy80ke',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Map Overlay Elements
                    Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Courier is nearby',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.navigation,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Sheet Card
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ESTIMATED ARRIVAL',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[500],
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '2:30 PM - 3:00 PM',
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.slate900,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.schedule,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 24),

                            // Courier Info
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCo5pdDUtDEurj_PkftmKLYNMtxvZBuDX5uYXqq2HQLr2Hg2YDbGPEkdpqO2DKmz96msZX0lomqOy5ZkzaTBOyQdPPyoADKMlrHMGoXBEdaTxDgO0_LaSPnH7V96lWgzuX-SnE5Mkxv_lTdaTsGrAb-exYIC1whGZ4u47NIIj_A9bhk638Tu6YsQs2mhtx5zBhOMnSCTMNTMq6hdx69-CQjvCcPHKZJM0m-UWtBRXMecV8A_zzlyOD2JdINbED_1gxEqMPKv-gnL-Pd',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'COURIER NAME',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[500],
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    Text(
                                      'Marcus Johnson',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.slate900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Delivery Address
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DELIVERY ADDRESS',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[500],
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      Text(
                                        '245 Market St, Suite 1500\nSan Francisco, CA 94105',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.slate900,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Contact Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.slate900,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.chat_bubble, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Contact Courier',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
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
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: 4, // Profile/Orders context
            onTap: (index) {
              if (index == 0) {
                Navigator.popUntil(context, (route) => route.isFirst);
              } else if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
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
        );
      },
    );
  }

  Widget _buildStatusStep(
    String label,
    bool isCompleted,
    bool isActive, {
    IconData? icon,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted || isActive
                ? AppColors.primary
                : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon ?? Icons.check,
            size: 16,
            color: isCompleted || isActive
                ? AppColors.slate900
                : Colors.grey[400],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isCompleted || isActive
                ? AppColors.slate900
                : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(bool isActive) {
    return Container(
      height: 2,
      color: isActive ? AppColors.primary : Colors.grey[200],
      margin: const EdgeInsets.only(
        bottom: 14,
      ), // Align with circle center roughly
    );
  }
}
