import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_back_button.dart';
import 'product_details_screen.dart';

class UserReviewsScreen extends StatefulWidget {
  const UserReviewsScreen({super.key});

  @override
  State<UserReviewsScreen> createState() => _UserReviewsScreenState();
}

class _UserReviewsScreenState extends State<UserReviewsScreen> {
  bool _isBackfilling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      _maybeBackfillUserReviews(uid);
    });
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
    return '$m ${dt.day}, ${dt.year}';
  }

  Future<void> _maybeBackfillUserReviews(String uid) async {
    if (_isBackfilling) return;
    setState(() {
      _isBackfilling = true;
    });

    try {
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('reviews')
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) return;

      final group = await FirebaseFirestore.instance
          .collectionGroup('reviews')
          .where('userId', isEqualTo: uid)
          .get();

      if (group.docs.isEmpty) return;

      final batch = FirebaseFirestore.instance.batch();
      for (final d in group.docs) {
        final productId = d.reference.parent.parent?.id ?? '';
        if (productId.trim().isEmpty) continue;

        Map<String, dynamic> productData = const {};
        try {
          final productDoc = await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .get();
          productData = productDoc.data() ?? const {};
        } catch (_) {}

        final brand = (productData['brand'] ?? '').toString().trim();
        final model = (productData['model'] ?? '').toString().trim();
        final combinedName = [
          brand,
          model,
        ].where((e) => e.isNotEmpty).join(' ').trim();
        final productName = combinedName.isNotEmpty
            ? combinedName
            : (productData['title'] ?? 'Product').toString().trim();

        final rawImageUrls = productData['imageUrls'] ?? productData['images'];
        final imageUrls = <String>[
          if (rawImageUrls is List)
            for (final u in rawImageUrls)
              if (u is String && u.trim().isNotEmpty) u.trim(),
        ];
        final productImage =
            (imageUrls.isNotEmpty
                    ? imageUrls.first
                    : (productData['imageUrl'] ?? productData['image'] ?? '')
                          .toString())
                .trim();

        final reviewData = d.data();
        final rating = (reviewData['rating'] is num)
            ? (reviewData['rating'] as num).toInt()
            : 5;
        final reviewText = (reviewData['review'] ?? '').toString().trim();
        final createdAtRaw = reviewData['createdAt'];
        final createdAt = createdAtRaw is Timestamp
            ? createdAtRaw
            : Timestamp.fromDate(DateTime.now());

        batch.set(
          FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('reviews')
              .doc(productId),
          <String, dynamic>{
            'productId': productId,
            'productName': productName,
            'productImage': productImage,
            'rating': rating,
            'review': reviewText,
            'createdAt': createdAt,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    } catch (_) {
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isBackfilling = false;
        });
      }
    }
  }

  Future<void> _openProductDetails(
    BuildContext context,
    String productId,
  ) async {
    Map<String, dynamic> product = {'id': productId};
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      final data = doc.data();
      if (doc.exists && data != null) {
        product = <String, dynamic>{...data, 'id': doc.id};
      }
    } catch (_) {}

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  Widget _stars(int rating) {
    final r = rating.clamp(0, 5);
    return Row(
      children: List.generate(5, (i) {
        final filled = i < r;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 16,
          color: filled ? AppColors.primary : Colors.grey[400],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: const Center(child: CustomBackButton()),
          title: Text(
            'My Reviews',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Text(
              'Please sign in to view your reviews.',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.slate900,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const Center(child: CustomBackButton()),
        title: Text(
          'My Reviews',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('reviews')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? const [];
            if (docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isBackfilling) ...[
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        _isBackfilling
                            ? 'Loading your reviews...'
                            : 'No reviews yet.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final data = docs[index].data();
                final productId = (data['productId'] ?? docs[index].id)
                    .toString()
                    .trim();
                final productName = (data['productName'] ?? 'Product')
                    .toString()
                    .trim();
                final productImage = (data['productImage'] ?? '')
                    .toString()
                    .trim();
                final rating = (data['rating'] is num)
                    ? (data['rating'] as num).toInt()
                    : 5;
                final review = (data['review'] ?? '').toString().trim();
                final createdAtTs = data['createdAt'];
                final createdAt = createdAtTs is Timestamp
                    ? createdAtTs.toDate()
                    : DateTime.now();

                return GestureDetector(
                  onTap: productId.isEmpty
                      ? null
                      : () => _openProductDetails(context, productId),
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: productImage.isEmpty
                                  ? const SizedBox.shrink()
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        productImage,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const SizedBox.shrink(),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productName,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.slate900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _stars(rating),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _formatDate(createdAt),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        if (review.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            review,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              height: 1.45,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
