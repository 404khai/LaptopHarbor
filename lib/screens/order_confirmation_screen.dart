import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_back_button.dart';
import 'order_details_screen.dart';
import 'package_tracking_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String? orderId;

  const OrderConfirmationScreen({super.key, this.orderId});

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

  String _formatDate(DateTime dt) {
    const months = <int, String>{
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'May',
      6: 'Jun',
      7: 'Jul',
      8: 'Aug',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Dec',
    };
    final m = months[dt.month] ?? 'Jan';
    return '$m ${dt.day}';
  }

  String _formatRange(DateTime start, DateTime end) {
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final resolvedOrderId = orderId;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const Center(child: CustomBackButton()),
        title: Text(
          'Order Status',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
      ),
      body: SafeArea(
        child: resolvedOrderId == null
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Order Confirmed!',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "Your order has been placed successfully. We'll notify you once it ships.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDPfZczVSKuQa2gHCNHm2qr8JJDz_GlADs-YosG0rbg7UUPecIUH_T5WE9gtvrHroiTgVoT4V9EiIhMZ0LOmnvcaohLuJ9YChIkC3nhKzuJEFm4b01OYkM4WesuUgCs-QsQN4TKuIIx7Qn_fyLCNhPIWVQRJu6x7i2eItKkQfKjvc1dGxK05r69HHDUvKzM9pv4nj3upOr7Njbwya0xT7JLDTADtBvevB4Uvejahw6rsSwlGgeO_ytodcvLbH2_baZHqwu3iL_cXqQC',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ESTIMATED DELIVERY',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatRange(
                                DateTime.now(),
                                DateTime.now().add(const Duration(days: 3)),
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.slate900,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Continue Shopping',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.slate900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : uid == null
            ? Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'Please sign in to view order confirmation.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate900,
                    ),
                  ),
                ),
              )
            : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('orders')
                    .doc(resolvedOrderId)
                    .snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data();
                  final orderNumber = (data?['orderNumber'] ?? '#')
                      .toString()
                      .trim();
                  final createdAtTs = data?['createdAt'];
                  final createdAt = (createdAtTs is Timestamp)
                      ? createdAtTs.toDate()
                      : DateTime.now();
                  final derivedStatus = _statusFromCreatedAt(createdAt);
                  if (data != null && (data['status'] ?? '') != derivedStatus) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('orders')
                        .doc(resolvedOrderId)
                        .set(<String, dynamic>{
                          'status': derivedStatus,
                          'updatedAt': FieldValue.serverTimestamp(),
                        }, SetOptions(merge: true));
                  }

                  final startTs = data?['estimatedDeliveryStart'];
                  final endTs = data?['estimatedDeliveryEnd'];
                  final start = (startTs is Timestamp)
                      ? startTs.toDate()
                      : createdAt;
                  final end = (endTs is Timestamp)
                      ? endTs.toDate()
                      : createdAt.add(const Duration(days: 3));
                  final email = FirebaseAuth.instance.currentUser?.email ?? '';

                  final itemsRaw = data?['items'];
                  final items = (itemsRaw is List) ? itemsRaw : const [];
                  final firstItem = items.isNotEmpty && items.first is Map
                      ? (items.first as Map)
                      : null;
                  final firstName = (firstItem?['name'] ?? 'Order items')
                      .toString();
                  final firstQty = (firstItem?['quantity'] is num)
                      ? (firstItem?['quantity'] as num).toInt()
                      : 1;
                  final firstPrice = (firstItem?['lineTotal'] is num)
                      ? (firstItem?['lineTotal'] as num).toDouble()
                      : 0.0;
                  final firstImage = (firstItem?['image'] ?? '').toString();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Success Icon
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'Order Confirmed!',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slate900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(text: 'Your order '),
                                TextSpan(
                                  text: orderNumber,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slate900,
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      ' has been placed successfully. We\'ll notify you once it ships.',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Map/Delivery Card
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuDPfZczVSKuQa2gHCNHm2qr8JJDz_GlADs-YosG0rbg7UUPecIUH_T5WE9gtvrHroiTgVoT4V9EiIhMZ0LOmnvcaohLuJ9YChIkC3nhKzuJEFm4b01OYkM4WesuUgCs-QsQN4TKuIIx7Qn_fyLCNhPIWVQRJu6x7i2eItKkQfKjvc1dGxK05r69HHDUvKzM9pv4nj3upOr7Njbwya0xT7JLDTADtBvevB4Uvejahw6rsSwlGgeO_ytodcvLbH2_baZHqwu3iL_cXqQC',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.4),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ESTIMATED DELIVERY',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatRange(start, end),
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Item Details Card
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailsScreen(
                                  orderId: resolvedOrderId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey[100]!),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ITEM DETAILS',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        firstName,
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.slate900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${firstQty}x - ₦${firstPrice.toStringAsFixed(2)}',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  width: 80,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: firstImage.trim().isEmpty
                                      ? null
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            firstImage,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const SizedBox.shrink(),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Action Buttons
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PackageTrackingScreen(
                                    orderId: resolvedOrderId,
                                  ),
                                ),
                              );
                            },
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
                                const Icon(Icons.local_shipping, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  'Track Order',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.slate900,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Continue Shopping',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Footer Info
                        _buildFooterInfo(
                          Icons.mail_outline,
                          'Confirmation sent to ',
                          email.isEmpty ? 'your email' : email,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.help_outline,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Need help? ',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Contact Support',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildFooterInfo(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(width: 12),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
            children: [
              TextSpan(text: label),
              TextSpan(
                text: value,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
