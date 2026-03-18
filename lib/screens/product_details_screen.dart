import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../widgets/custom_back_button.dart';

enum _ReviewSortMode { all, recent, oldest }

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  late List<String> _images;
  final TextEditingController _reviewController = TextEditingController();
  int _reviewRating = 5;
  bool _isSubmittingReview = false;
  int? _reviewFilterRating;
  _ReviewSortMode _reviewSortMode = _ReviewSortMode.all;

  String _cartId() => _wishlistId();

  String _wishlistId() {
    final raw = (widget.product['id'] ?? '').toString().trim();
    if (raw.isNotEmpty) return raw;

    final brand = (widget.product['brand'] ?? '').toString().trim();
    final model = (widget.product['model'] ?? '').toString().trim();
    final title = (widget.product['title'] ?? '').toString().trim();
    final base = title.isNotEmpty ? title : '$brand $model'.trim();

    return base
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  String _productDocId() {
    final raw = (widget.product['id'] ?? '').toString().trim();
    if (raw.isNotEmpty) return raw;
    return _wishlistId();
  }

  String _formatReviewDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[(dt.month - 1).clamp(0, 11)];
    return '$m ${dt.day}, ${dt.year}';
  }

  Future<String> _resolveReviewerName(User user) async {
    final displayName = (user.displayName ?? '').trim();
    if (displayName.isNotEmpty) return displayName;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data();
    if (data == null) return 'Anonymous';

    final first = (data['firstName'] ?? data['firstname'] ?? '')
        .toString()
        .trim();
    final last = (data['lastName'] ?? data['lastname'] ?? '').toString().trim();
    final full = '$first $last'.trim();
    if (full.isNotEmpty) return full;

    final name = (data['name'] ?? '').toString().trim();
    if (name.isNotEmpty) return name;

    return 'Anonymous';
  }

  Future<void> _submitReview() async {
    if (_isSubmittingReview) return;

    final reviewText = _reviewController.text.trim();
    if (reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review first.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to submit a review.')),
      );
      return;
    }

    setState(() {
      _isSubmittingReview = true;
    });

    try {
      final name = await _resolveReviewerName(user);
      final productId = _productDocId();
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .add(<String, dynamic>{
            'userId': user.uid,
            'name': name,
            'rating': _reviewRating,
            'review': reviewText,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      setState(() {
        _reviewController.clear();
        _reviewRating = 5;
      });
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Review submitted.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to submit review.')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingReview = false;
        });
      }
    }
  }

  Product _toCartProduct() {
    final id = _cartId();

    String brand = (widget.product['brand'] ?? '').toString().trim();
    String model = (widget.product['model'] ?? '').toString().trim();
    final title = (widget.product['title'] ?? '').toString().trim();
    if ((brand.isEmpty || model.isEmpty) && title.isNotEmpty) {
      final parts = title.split(' ').where((p) => p.trim().isNotEmpty).toList();
      if (parts.isNotEmpty) {
        brand = brand.isEmpty ? parts.first : brand;
        model = model.isEmpty ? parts.skip(1).join(' ') : model;
      }
    }

    final rawImageUrls =
        widget.product['imageUrls'] ?? widget.product['images'];
    final imageUrl = (() {
      final image =
          (widget.product['imageUrl'] ?? widget.product['image'] ?? '')
              .toString()
              .trim();
      if (image.isNotEmpty) return image;
      if (rawImageUrls is List && rawImageUrls.isNotEmpty) {
        final first = rawImageUrls.first;
        if (first is String && first.trim().isNotEmpty) return first.trim();
      }
      return '';
    })();

    final priceValue = widget.product['price'];
    final price = (() {
      if (priceValue is num) return priceValue.toDouble();
      final s = priceValue?.toString() ?? '';
      final cleaned = s.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    })();

    final description = (widget.product['description'] ?? '').toString();
    final specs = widget.product['specifications'] is Map
        ? Map<String, dynamic>.from(widget.product['specifications'] as Map)
        : <String, dynamic>{};
    final category = (widget.product['category'] ?? '').toString();

    return Product(
      id: id,
      brand: brand,
      model: model,
      imageUrl: imageUrl,
      imageUrls: _images,
      price: price,
      originalPrice: null,
      description: description,
      specifications: specs,
      category: category,
    );
  }

  @override
  void initState() {
    super.initState();
    final dynamic rawUrls =
        widget.product['imageUrls'] ?? widget.product['images'];
    final urls = <String>[];

    if (rawUrls is List) {
      for (final item in rawUrls) {
        if (item is String && item.trim().isNotEmpty) {
          urls.add(item.trim());
        } else if (item != null) {
          final asString = item.toString().trim();
          if (asString.isNotEmpty && asString != 'null') {
            urls.add(asString);
          }
        }
      }
    }

    final fallbackImage =
        (widget.product['image'] ??
                widget.product['imageUrl'] ??
                widget.product['image_url'] ??
                '')
            .toString()
            .trim();
    if (urls.isEmpty && fallbackImage.isNotEmpty) {
      urls.add(fallbackImage);
    }

    final deduped = <String>[];
    for (final url in urls) {
      if (!deduped.contains(url)) deduped.add(url);
    }

    while (deduped.length < 4 && deduped.isNotEmpty) {
      deduped.add(deduped.first);
    }
    _images = deduped.take(4).toList();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carousel
                    _buildImageCarousel(),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Price
                          Text(
                            (widget.product['title'] ??
                                    'Quantum Pro X15 - Ultra Performance Laptop')
                                .toString(),
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slate900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (widget.product['price'] ?? '\$2,499.00')
                                .toString(),
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Specs Grid
                          _buildSpecsGrid(),

                          const SizedBox(height: 24),

                          // Action Buttons
                          _buildActionButtons(),

                          const SizedBox(height: 24),

                          // Expandable Sections
                          _buildExpandableSection(
                            title: 'Description',
                            content: Text(
                              'Experience uncompromised power with the Quantum Pro X15. Engineered for professionals and creators, it features a liquid-cooled thermal system and a stunning 4K OLED display.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                            isExpanded: true,
                          ),
                          _buildExpandableSection(
                            title: 'Specifications',
                            content: Column(
                              children: [
                                _buildSpecRow('Screen', '15.6" OLED 4K'),
                                _buildSpecRow('Battery', '99Wh (12 hrs)'),
                                _buildSpecRow('Weight', '1.8 kg'),
                              ],
                            ),
                          ),
                          _buildExpandableSection(
                            title: 'Reviews',
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.8',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Rating Summary
                                _buildRatingSummary(),
                                const SizedBox(height: 24),

                                _buildReviewFilters(),
                                const SizedBox(height: 16),

                                StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>
                                >(
                                  stream: (() {
                                    final base = FirebaseFirestore.instance
                                        .collection('products')
                                        .doc(_productDocId())
                                        .collection('reviews');
                                    final filtered = _reviewFilterRating == null
                                        ? base
                                        : base.where(
                                            'rating',
                                            isEqualTo: _reviewFilterRating,
                                          );
                                    return filtered
                                        .orderBy(
                                          'createdAt',
                                          descending:
                                              _reviewSortMode !=
                                              _ReviewSortMode.oldest,
                                        )
                                        .snapshots();
                                  })(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox.shrink();
                                    }
                                    if (snapshot.hasError) {
                                      return const SizedBox.shrink();
                                    }
                                    final docs =
                                        snapshot.data?.docs ?? const [];
                                    final entries = <Map<String, dynamic>>[
                                      for (final d in docs)
                                        <String, dynamic>{
                                          'name':
                                              (d.data()['name'] ?? 'Anonymous')
                                                  .toString(),
                                          'createdAt': (() {
                                            final ts = d.data()['createdAt'];
                                            if (ts is Timestamp) {
                                              return ts.toDate();
                                            }
                                            return DateTime.fromMillisecondsSinceEpoch(
                                              0,
                                            );
                                          })(),
                                          'review': (d.data()['review'] ?? '')
                                              .toString(),
                                          'rating': (d.data()['rating'] is num)
                                              ? (d.data()['rating'] as num)
                                                    .toInt()
                                              : 0,
                                        },
                                      ..._staticReviewEntries(),
                                    ];

                                    final filteredEntries =
                                        _reviewFilterRating == null
                                        ? entries
                                        : entries
                                              .where(
                                                (e) =>
                                                    e['rating'] ==
                                                    _reviewFilterRating,
                                              )
                                              .toList();

                                    filteredEntries.sort((a, b) {
                                      final da = a['createdAt'] as DateTime;
                                      final db = b['createdAt'] as DateTime;
                                      if (_reviewSortMode ==
                                          _ReviewSortMode.oldest) {
                                        return da.compareTo(db);
                                      }
                                      return db.compareTo(da);
                                    });

                                    if (filteredEntries.isEmpty) {
                                      return Center(
                                        child: Text(
                                          'Result Not Found',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      );
                                    }

                                    return Column(
                                      children: [
                                        for (final e in filteredEntries) ...[
                                          _buildReviewItem(
                                            (e['name'] ?? 'Anonymous')
                                                .toString(),
                                            _formatReviewDate(
                                              e['createdAt'] as DateTime,
                                            ),
                                            (e['review'] ?? '').toString(),
                                            (e['rating'] is num)
                                                ? (e['rating'] as num).toInt()
                                                : 0,
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Write a Review Section
                          _buildWriteReviewSection(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final wishlist = context.watch<WishlistProvider>();
    final productId = _wishlistId();
    final isWishlisted = productId.isNotEmpty && wishlist.containsId(productId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomBackButton(),
          Expanded(
            child: Text(
              'Product Details',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                ),
                onPressed: () {
                  wishlist.toggleFromProduct(widget.product);
                },
                color: isWishlisted ? Colors.red : AppColors.slate900,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {},
                color: AppColors.slate900,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: 300, // Aspect ratio roughly square or 4:3
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  image: DecorationImage(
                    image: NetworkImage(_images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? AppColors.primary
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildSpecItem(Icons.memory, '16GB RAM'),
        _buildSpecItem(Icons.storage, '1TB SSD'), // storage icon for hard_drive
        _buildSpecItem(
          Icons.developer_board,
          'Intel i9 Gen 14',
        ), // developer_board for processing_cluster
        _buildSpecItem(Icons.videogame_asset, 'RTX 4080'),
      ],
    );
  }

  Widget _buildSpecItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.slate900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final wishlist = context.watch<WishlistProvider>();
    final productId = _wishlistId();
    final isWishlisted = productId.isNotEmpty && wishlist.containsId(productId);
    final cart = context.watch<CartProvider>();
    final cartId = _cartId();
    final cartItem = cart.cartItems.cast<Map<String, dynamic>?>().firstWhere(
      (e) => e != null && (e['id'] ?? '').toString() == cartId,
      orElse: () => null,
    );
    final cartQuantity = (cartItem?['quantity'] is num)
        ? (cartItem?['quantity'] as num).toInt()
        : 0;

    return Column(
      children: [
        if (cartQuantity <= 0)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                cart.addToCart(_toCartProduct(), 1);
              },
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.qtyBg,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (cartQuantity <= 1) {
                        cart.removeFromCart(cartId);
                      } else {
                        cart.updateQuantity(cartId, -1);
                      }
                    },
                    icon: const Icon(Icons.remove),
                    color: AppColors.slate900,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                Text(
                  '$cartQuantity',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.background,
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.qtyBg,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    onPressed: () {
                      cart.updateQuantity(cartId, 1);
                    },
                    icon: const Icon(Icons.add),
                    color: AppColors.slate900,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              wishlist.toggleFromProduct(widget.product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.slate900,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isWishlisted
                      ? Icons.favorite
                      : Icons.favorite_border_outlined,
                  size: 20,
                  color: isWishlisted ? Colors.red : Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  isWishlisted ? 'Remove from Wishlist' : 'Add to Wishlist',
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
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required Widget content,
    Widget? trailing,
    bool isExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          tilePadding: EdgeInsets.zero,
          title: Row(
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing],
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.slate900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '4.8',
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.slate900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < 4 ? Icons.star : Icons.star_half,
                      size: 20,
                      color: AppColors.slate900,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on 1,240 verified reviews',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  _buildRatingBar(5, 0.85),
                  _buildRatingBar(4, 0.10),
                  _buildRatingBar(3, 0.03),
                  _buildRatingBar(2, 0.01),
                  _buildRatingBar(1, 0.01),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingBar(int star, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              '$star',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.slate900,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildSortFilterChip(
            'All',
            isActive: _reviewSortMode == _ReviewSortMode.all,
            onTap: () {
              setState(() {
                _reviewSortMode = _ReviewSortMode.all;
                _reviewFilterRating = null;
              });
            },
          ),
          const SizedBox(width: 12),
          _buildSortFilterChip(
            'Recent',
            isActive: _reviewSortMode == _ReviewSortMode.recent,
            onTap: () {
              setState(() {
                _reviewSortMode = _ReviewSortMode.recent;
              });
            },
          ),
          const SizedBox(width: 12),
          _buildSortFilterChip(
            'Oldest',
            isActive: _reviewSortMode == _ReviewSortMode.oldest,
            onTap: () {
              setState(() {
                _reviewSortMode = _ReviewSortMode.oldest;
              });
            },
          ),
          const SizedBox(width: 12),
          for (final rating in [5, 4, 3, 2, 1]) ...[
            _buildRatingFilterChip(rating),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildSortFilterChip(
    String label, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.slate900 : AppColors.slate50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.slate100),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : AppColors.slate900,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingFilterChip(int rating) {
    final isActive = _reviewFilterRating == rating;
    return GestureDetector(
      onTap: () {
        setState(() {
          _reviewFilterRating = isActive ? null : rating;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.slate900 : AppColors.slate50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.slate100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$rating',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : AppColors.slate900,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.star,
              size: 16,
              color: isActive ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  DateTime _parseReviewDate(String value) {
    final months = <String, int>{
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    final parts = value.split(RegExp(r'\s+'));
    if (parts.length < 3) return DateTime.fromMillisecondsSinceEpoch(0);
    final month = months[parts[0]] ?? 1;
    final day = int.tryParse(parts[1].replaceAll(',', '')) ?? 1;
    final year = int.tryParse(parts[2]) ?? 1970;
    return DateTime(year, month, day);
  }

  List<Map<String, dynamic>> _staticReviewEntries() {
    final reviews = [
      {
        'name': 'Alex Johnson',
        'date': 'Oct 24, 2023',
        'review':
            'The build quality on this laptop is insane. Best purchase for my dev workflow. The keyboard travel is perfect for long coding sessions and the screen color accuracy is professional grade.',
        'rating': 5,
      },
      {
        'name': 'Sarah Chen',
        'date': 'Oct 15, 2023',
        'review':
            'Stunning display and the battery life actually lasts all day. Highly recommend! The OLED panel makes creative work a joy. Shipping was also faster than expected.',
        'rating': 5,
      },
      {
        'name': 'Michael Ross',
        'date': 'Oct 08, 2023',
        'review':
            'Great performance, though it runs a bit hot under heavy loads. Overall, a solid machine for the price point.',
        'rating': 4,
      },
    ];

    return [
      for (final r in reviews)
        <String, dynamic>{
          'name': r['name'],
          'createdAt': _parseReviewDate(r['date'] as String),
          'review': r['review'],
          'rating': r['rating'],
        },
    ];
  }

  Widget _buildReviewItem(String name, String date, String review, int rating) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name[0],
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      Text(
                        date,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: AppColors.ratingColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.slate900, // Slightly darker text for readability
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWriteReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Write a Review',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        const SizedBox(height: 16),
        // Product Context (Optional but good for UX)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _images.isNotEmpty ? _images.first : '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REVIEWING',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (widget.product['title'] ?? '').toString(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Overall Rating
        Text(
          'Overall Rating',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Row(
              children: List.generate(
                5,
                (index) => IconButton(
                  onPressed: () {
                    setState(() {
                      _reviewRating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _reviewRating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 32,
                  ),
                  color: index < _reviewRating
                      ? const Color(0xFFFFC107)
                      : Colors.grey[300],
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _reviewRating.toDouble().toStringAsFixed(1),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Review Body
        Text(
          'REVIEW BODY',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _reviewController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Share your thoughts about this laptop...',
              hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: true,
              fillColor: Colors.grey[100],
            ),
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.slate900),
          ),
        ),
        const SizedBox(height: 32),
        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSubmittingReview ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.slate900,
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'SUBMIT REVIEW',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text.rich(
            TextSpan(
              text: 'By submitting, you agree to LaptopHarbor\'s ',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
              children: [
                TextSpan(
                  text: 'Community Guidelines',
                  style: GoogleFonts.inter(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
