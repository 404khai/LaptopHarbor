import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:async';
import 'product_details_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_back_button.dart';
import '../utils/money.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _showResults = false;
  final List<String> _recentSearches = [];
  bool _isLoadingSuggestions = false;
  List<Map<String, dynamic>> _suggestions = [];
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _recentSub;
  String? _uid;

  String? _brandFilter;
  RangeValues? _priceRange;
  bool _inStockOnly = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    final initial = widget.initialQuery?.trim() ?? '';
    if (initial.isNotEmpty) {
      _searchController.text = initial;
      _searchController.selection = TextSelection.collapsed(
        offset: initial.length,
      );
      _showResults = true;
      _addRecentSearch(initial);
      _persistRecentSearch(initial);
    }
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _attachRecentListener();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _uid = user?.uid;
      _attachRecentListener();
    });
    _loadSuggestions();
  }

  void _onSearchChanged() {
    setState(() {
      _showResults = _searchController.text.isNotEmpty;
    });
  }

  void _addRecentSearch(String term) {
    final t = term.trim();
    if (t.isEmpty) return;

    final normalized = t.toLowerCase();
    _recentSearches.removeWhere((e) => e.toLowerCase() == normalized);
    _recentSearches.insert(0, t);
    if (_recentSearches.length > 3) {
      _recentSearches.removeRange(3, _recentSearches.length);
    }
  }

  void _submitSearch(String term) {
    final t = term.trim();
    if (t.isEmpty) return;
    setState(() {
      _addRecentSearch(t);
      _showResults = true;
    });
    _persistRecentSearch(t);
  }

  void _applySearchTerm(String term) {
    final t = term.trim();
    if (t.isEmpty) return;
    _searchController.text = t;
    _searchController.selection = TextSelection.collapsed(offset: t.length);
    _submitSearch(t);
  }

  Future<void> _loadSuggestions() async {
    if (!mounted) return;
    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      final snap = await FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: 'Laptop')
          .limit(25)
          .get();

      final docs = snap.docs.toList();
      docs.shuffle(Random());
      final picked = docs.take(4);

      final list = <Map<String, dynamic>>[];
      for (final d in picked) {
        final data = d.data();
        list.add(<String, dynamic>{...data, 'id': d.id});
      }

      if (mounted) {
        setState(() {
          _suggestions = list;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _suggestions = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSuggestions = false;
        });
      }
    }
  }

  String _recentDocId(String term) {
    final t = term.trim().toLowerCase();
    return t
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  void _attachRecentListener() {
    _recentSub?.cancel();
    _recentSub = null;

    final uid = _uid;
    if (uid == null) return;

    _recentSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('recentSearches')
        .orderBy('updatedAt', descending: true)
        .limit(3)
        .snapshots()
        .listen((snapshot) {
          final terms = snapshot.docs
              .map((d) => (d.data()['term'] ?? '').toString().trim())
              .where((t) => t.isNotEmpty)
              .toList();
          if (!mounted) return;
          setState(() {
            _recentSearches
              ..clear()
              ..addAll(terms);
          });
        });
  }

  Future<void> _persistRecentSearch(String term) async {
    final uid = _uid;
    if (uid == null) return;

    final t = term.trim();
    if (t.isEmpty) return;

    final docId = _recentDocId(t);
    if (docId.isEmpty) return;

    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('recentSearches');

    await col.doc(docId).set(<String, dynamic>{
      'term': t,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final snap = await col.orderBy('updatedAt', descending: true).get();
    if (snap.docs.length <= 3) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final d in snap.docs.skip(3)) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  Future<void> _clearAllRecentSearches() async {
    final uid = _uid;
    setState(() {
      _recentSearches.clear();
    });
    if (uid == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('recentSearches')
        .get();
    if (snap.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  String? _categoryFilterFromQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return null;

    final normalized = q.endsWith('s') ? q.substring(0, q.length - 1) : q;

    if (normalized.contains('laptop bag') ||
        normalized == 'bag' ||
        normalized == 'bags') {
      return 'Laptop Bag';
    }
    if (normalized == 'laptop' || normalized == 'laptops') return 'Laptop';
    if (normalized == 'mouse' || normalized == 'mice') return 'Mouse';
    if (normalized == 'keyboard' || normalized == 'keyboards') {
      return 'Keyboard';
    }
    if (normalized == 'charger' || normalized == 'chargers') return 'Charger';

    return null;
  }

  bool _matchesQuery(Map<String, dynamic> product, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;

    final brand = (product['brand'] ?? '').toString().toLowerCase();
    final model = (product['model'] ?? '').toString().toLowerCase();
    final category = (product['category'] ?? '').toString().toLowerCase();
    final title = (product['title'] ?? '').toString().toLowerCase();

    return brand.contains(q) ||
        model.contains(q) ||
        category.contains(q) ||
        title.contains(q);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _recentSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().totalQuantity;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const Center(child: CustomBackButton()),
        title: Text(
          'Search',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartCount',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _submitSearch,
                  decoration: InputDecoration(
                    hintText: 'Search laptops...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.cancel,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: GoogleFonts.inter(fontSize: 16, color: AppColors.text),
                ),
              ),
            ),

            Expanded(
              child: _showResults
                  ? _buildSearchResults()
                  : _buildRecentAndSuggestions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAndSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT SEARCHES',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.subtext,
                  letterSpacing: 0.5,
                ),
              ),
              TextButton(
                onPressed: _clearAllRecentSearches,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear All',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_recentSearches.isEmpty)
            Text(
              'No recent searches',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[400],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches
                  .map((term) => _buildRecentSearchChip(term))
                  .toList(),
            ),
          const SizedBox(height: 32),

          // Suggestions
          Text(
            'SUGGESTIONS',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.subtext,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoadingSuggestions)
            const Center(child: CircularProgressIndicator())
          else if (_suggestions.isEmpty)
            Text(
              'No suggestions',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[400],
              ),
            )
          else
            ..._suggestions.map(_buildSuggestionItem),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchText = _searchController.text;
    final categoryFilter = _categoryFilterFromQuery(searchText);
    final query = categoryFilter != null
        ? FirebaseFirestore.instance
              .collection('products')
              .where('category', isEqualTo: categoryFilter)
        : FirebaseFirestore.instance.collection('products');

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final docs = snapshot.data?.docs ?? const [];
        final brandOptions = <String>{
          for (final d in docs) ((d.data()['brand'] ?? '').toString().trim()),
        }..removeWhere((e) => e.isEmpty);

        final prices = docs
            .map((d) => d.data()['price'])
            .whereType<num>()
            .map((n) => n.toDouble())
            .toList();
        final minPrice = prices.isEmpty ? 0.0 : prices.reduce(min);
        final maxPrice = prices.isEmpty ? 5000.0 : prices.reduce(max);
        _priceRange ??= RangeValues(minPrice, maxPrice);

        final items = docs
            .map((d) => <String, dynamic>{...d.data(), 'id': d.id})
            .where(
              (p) =>
                  categoryFilter != null ? true : _matchesQuery(p, searchText),
            )
            .where((p) {
              if (_brandFilter == null || _brandFilter!.trim().isEmpty) {
                return true;
              }
              return (p['brand'] ?? '').toString() == _brandFilter;
            })
            .where((p) {
              final range = _priceRange;
              if (range == null) return true;
              final raw = p['price'];
              final price = raw is num
                  ? raw.toDouble()
                  : double.tryParse('$raw') ?? 0.0;
              return price >= range.start && price <= range.end;
            })
            .where((p) {
              if (!_inStockOnly) return true;
              final inStock =
                  p['inStock'] == true ||
                  ((p['stock'] is num) && (p['stock'] as num).toInt() > 0);
              return inStock;
            })
            .map((p) {
              final imageUrls = <String>[];
              final rawImageUrls = p['imageUrls'] ?? p['images'];
              if (rawImageUrls is List) {
                for (final item in rawImageUrls) {
                  if (item is String && item.trim().isNotEmpty) {
                    imageUrls.add(item.trim());
                  }
                }
              }

              final fallbackImage = (p['imageUrl'] ?? p['image'] ?? '')
                  .toString()
                  .trim();
              if (imageUrls.isEmpty && fallbackImage.isNotEmpty) {
                imageUrls.add(fallbackImage);
              }
              while (imageUrls.length < 4 && imageUrls.isNotEmpty) {
                imageUrls.add(imageUrls.first);
              }

              final brand = (p['brand'] ?? '').toString();
              final model = (p['model'] ?? '').toString();
              final priceRaw = p['price'];
              final price = priceRaw is num
                  ? priceRaw.toDouble()
                  : double.tryParse('$priceRaw') ?? 0.0;

              final inStock =
                  p['inStock'] == true ||
                  ((p['stock'] is num) && (p['stock'] as num).toInt() > 0);

              return <String, dynamic>{
                ...p,
                'title': '$brand $model'.trim(),
                'price': price,
                'image': imageUrls.isNotEmpty ? imageUrls.first : '',
                'imageUrls': imageUrls.take(4).toList(),
                'stock': inStock ? 'IN STOCK' : 'OUT OF STOCK',
              };
            })
            .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${items.length} results',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _showFilterSheet(
                        context,
                        brands: brandOptions.toList()..sort(),
                        minPrice: minPrice,
                        maxPrice: maxPrice,
                      );
                    },
                    icon: const Icon(Icons.tune, size: 16, color: Colors.grey),
                    label: Text(
                      'Filter',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildResultCard(items[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFilterSheet(
    BuildContext context, {
    required List<String> brands,
    required double minPrice,
    required double maxPrice,
  }) async {
    final initialBrand = _brandFilter;
    final initialRange = _priceRange ?? RangeValues(minPrice, maxPrice);
    final initialInStockOnly = _inStockOnly;

    String? brand = initialBrand;
    RangeValues range = RangeValues(
      initialRange.start.clamp(minPrice, maxPrice),
      initialRange.end.clamp(minPrice, maxPrice),
    );
    bool inStockOnly = initialInStockOnly;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final height = MediaQuery.of(context).size.height * 0.5;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: height,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Filter',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    value: brand,
                    decoration: InputDecoration(
                      labelText: 'Brand',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Any'),
                      ),
                      ...brands.map(
                        (b) =>
                            DropdownMenuItem<String?>(value: b, child: Text(b)),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        brand = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Price',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(Money.ngn(range.start)),
                      Text(Money.ngn(range.end)),
                    ],
                  ),
                  RangeSlider(
                    min: minPrice,
                    max: maxPrice,
                    values: range,
                    onChanged: (values) {
                      setModalState(() {
                        range = values;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: inStockOnly ? 'In stock' : 'Any',
                    decoration: InputDecoration(
                      labelText: 'Availability',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Any', child: Text('Any')),
                      DropdownMenuItem(
                        value: 'In stock',
                        child: Text('In stock'),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        inStockOnly = value == 'In stock';
                      });
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.slate900,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _brandFilter = brand;
                          _priceRange = range;
                          _inStockOnly = inStockOnly;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Apply Filters',
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
          },
        );
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        final images = <String>[];
        final rawImageUrls = item['imageUrls'] ?? item['images'];
        if (rawImageUrls is List) {
          for (final value in rawImageUrls) {
            if (value is String && value.trim().isNotEmpty) {
              images.add(value.trim());
            }
          }
        }
        final image = (item['image'] ?? item['imageUrl'] ?? '')
            .toString()
            .trim();
        if (images.isEmpty && image.isNotEmpty) {
          images.add(image);
        }
        while (images.length < 4 && images.isNotEmpty) {
          images.add(images.first);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              product: {...item, 'imageUrls': images.take(4).toList()},
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  (item['image'] ?? item['imageUrl'] ?? '').toString(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (item['stock'] ?? '').toString(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (item['title'] ?? '').toString(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Money.ngn(item['price']),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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

  Widget _buildRecentSearchChip(String label) {
    return GestureDetector(
      onTap: () => _applySearchTerm(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(Map<String, dynamic> product) {
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

    final brand = (product['brand'] ?? '').toString();
    final model = (product['model'] ?? '').toString();
    final title = '$brand $model'.trim();
    final priceRaw = product['price'];
    final price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse('$priceRaw') ?? 0.0;
    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          _applySearchTerm(title);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                product: {
                  ...product,
                  'title': title,
                  'price': price,
                  'image': imageUrl,
                  'imageUrls': imageUrls.take(4).toList(),
                },
              ),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Money.ngn(price),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.north_west, color: AppColors.slate300, size: 20),
          ],
        ),
      ),
    );
  }
}
