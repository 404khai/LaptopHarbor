import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/custom_back_button.dart';

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

                                // Tabs
                                _buildReviewTabs(),
                                const SizedBox(height: 16),

                                // Reviews List
                                _buildReviewItem(
                                  'Alex Johnson',
                                  'Oct 24, 2023',
                                  'The build quality on this laptop is insane. Best purchase for my dev workflow. The keyboard travel is perfect for long coding sessions and the screen color accuracy is professional grade.',
                                  5,
                                  124,
                                  2,
                                ),
                                const SizedBox(height: 12),
                                _buildReviewItem(
                                  'Sarah Chen',
                                  'Oct 15, 2023',
                                  'Stunning display and the battery life actually lasts all day. Highly recommend! The OLED panel makes creative work a joy. Shipping was also faster than expected.',
                                  5,
                                  89,
                                  0,
                                ),
                                const SizedBox(height: 12),
                                _buildReviewItem(
                                  'Michael Ross',
                                  'Oct 08, 2023',
                                  'Great performance, though it runs a bit hot under heavy loads. Overall, a solid machine for the price point.',
                                  4,
                                  42,
                                  1,
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

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
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

  Widget _buildReviewTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildTabItem('All', true),
            const SizedBox(width: 24),
            _buildTabItem('With Photos', false),
            const SizedBox(width: 24),
            _buildTabItem('Most Recent', false),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.filter_list, size: 20, color: Colors.grey),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildTabItem(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? AppColors.slate900 : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          color: isActive ? AppColors.slate900 : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildReviewItem(
    String name,
    String date,
    String review,
    int rating,
    int likes,
    int dislikes,
  ) {
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
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.thumb_up_outlined, size: 18, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                '$likes',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.thumb_down_outlined,
                size: 18,
                color: Colors.grey[500],
              ),
              if (dislikes > 0) ...[
                const SizedBox(width: 6),
                Text(
                  '$dislikes',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
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
                  onPressed: () {}, // Make interactive if needed
                  icon: const Icon(Icons.star_rounded, size: 32),
                  color: index < 4
                      ? const Color(0xFFFFC107)
                      : Colors.grey[300], // Yellow stars
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
              '4.0',
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
            onPressed: () {},
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
