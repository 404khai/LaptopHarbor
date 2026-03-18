import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../screens/product_details_screen.dart';
import '../screens/search_screen.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_theme.dart';

class FirestoreProductSection extends StatefulWidget {
  final String title;
  final String category;
  final int limit;
  final bool randomize;
  final int randomizePoolSize;

  const FirestoreProductSection({
    super.key,
    required this.title,
    required this.category,
    this.limit = 6,
    this.randomize = false,
    this.randomizePoolSize = 25,
  });

  @override
  State<FirestoreProductSection> createState() =>
      _FirestoreProductSectionState();
}

class _FirestoreProductSectionState extends State<FirestoreProductSection> {
  late final int _randomSeed;

  @override
  void initState() {
    super.initState();
    _randomSeed = DateTime.now().microsecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: widget.category)
        .limit(widget.randomize ? widget.randomizePoolSize : widget.limit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SearchScreen(initialQuery: widget.title),
                    ),
                  );
                },
                child: Row(
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
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              final docs = snapshot.data?.docs.toList() ?? const [];
              if (docs.isEmpty) {
                return Center(child: Text('No ${widget.title} found'));
              }

              if (widget.randomize && docs.isNotEmpty) {
                docs.shuffle(Random(_randomSeed));
              }
              final shownDocs = docs.take(widget.limit).toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.70,
                ),
                itemCount: shownDocs.length,
                itemBuilder: (context, index) {
                  final data = shownDocs[index].data();
                  final product = <String, dynamic>{
                    ...data,
                    'id': shownDocs[index].id,
                  };
                  return _ProductCard(product: product);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  String _wishlistId() {
    final raw = (product['id'] ?? '').toString().trim();
    if (raw.isNotEmpty) return raw;

    final brand = (product['brand'] ?? '').toString().trim();
    final model = (product['model'] ?? '').toString().trim();
    final title = (product['title'] ?? '').toString().trim();
    final base = title.isNotEmpty ? title : '$brand $model'.trim();

    return base
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = <String>[];
    final rawImageUrls = product['imageUrls'] ?? product['images'];
    if (rawImageUrls is List) {
      for (final item in rawImageUrls) {
        if (item is String && item.trim().isNotEmpty) {
          imageUrls.add(item.trim());
        }
      }
    }
    final fallbackImage = (product['imageUrl'] ?? product['image'] ?? '')
        .toString()
        .trim();
    if (imageUrls.isEmpty && fallbackImage.isNotEmpty) {
      imageUrls.add(fallbackImage);
    }
    while (imageUrls.length < 4 && imageUrls.isNotEmpty) {
      imageUrls.add(imageUrls.first);
    }

    final image = imageUrls.isNotEmpty ? imageUrls.first : '';
    final brand = (product['brand'] ?? '').toString();
    final model = (product['model'] ?? '').toString();

    final priceRaw = product['price'];
    final wishlist = context.watch<WishlistProvider>();
    final isWishlisted = wishlist.containsId(_wishlistId());

    final price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse('$priceRaw') ?? 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              product: {
                ...product,
                'title': '$brand $model'.trim(),
                'price': '\$${price.toStringAsFixed(2)}',
                'image': image,
                'imageUrls': imageUrls.take(4).toList(),
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
                        image,
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
                      child: GestureDetector(
                        onTap: () {
                          context.read<WishlistProvider>().toggleFromProduct(
                            product,
                          );
                        },
                        child: Icon(
                          isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: isWishlisted ? Colors.red : AppColors.slate900,
                        ),
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
                    brand,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    model,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
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
