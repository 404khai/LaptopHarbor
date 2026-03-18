import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _wishlistSub;
  String? _uid;
  final Set<String> _categoryBackfillInFlight = {};

  WishlistProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _uid = user?.uid;
      _attachWishlistListener();
    });
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _attachWishlistListener();
  }

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  bool containsId(String id) {
    return _items.any((e) => (e['id'] ?? '').toString() == id);
  }

  void addFromProduct(Map<String, dynamic> product) {
    final id = _productId(product);
    if (id.isEmpty) return;
    if (_uid == null) {
      if (containsId(id)) return;
      _items.insert(0, _toWishlistItem(product));
      notifyListeners();
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('wishlist')
        .doc(id);
    docRef.set(<String, dynamic>{
      ..._toWishlistItem(product),
      'createdAt': FieldValue.serverTimestamp(),
      'productId': id,
    });
  }

  void removeById(String id) {
    if (_uid == null) {
      _items.removeWhere((e) => (e['id'] ?? '').toString() == id);
      notifyListeners();
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('wishlist')
        .doc(id)
        .delete();
  }

  void toggleFromProduct(Map<String, dynamic> product) {
    final id = _productId(product);
    if (id.isEmpty) return;
    if (containsId(id)) {
      removeById(id);
    } else {
      addFromProduct(product);
    }
  }

  void _attachWishlistListener() {
    _wishlistSub?.cancel();
    _wishlistSub = null;
    _items.clear();
    notifyListeners();

    final uid = _uid;
    if (uid == null) return;

    _wishlistSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _items
            ..clear()
            ..addAll(
              snapshot.docs.map((d) {
                final data = d.data();
                return <String, dynamic>{
                  ...data,
                  'id': (data['id'] ?? d.id).toString(),
                };
              }),
            );
          notifyListeners();
          _backfillMissingCategories(uid, snapshot.docs);
        });
  }

  Future<void> _backfillMissingCategories(
    String uid,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    for (final d in docs) {
      final data = d.data();
      final category = (data['category'] ?? '').toString().trim();
      if (category.isNotEmpty) continue;

      final productId = (data['productId'] ?? d.id).toString().trim();
      if (productId.isEmpty) continue;
      if (_categoryBackfillInFlight.contains(productId)) continue;
      _categoryBackfillInFlight.add(productId);

      try {
        final productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();
        final productData = productDoc.data();
        final fetchedCategory = (productData?['category'] ?? '')
            .toString()
            .trim();
        if (fetchedCategory.isEmpty) continue;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('wishlist')
            .doc(d.id)
            .set(<String, dynamic>{
              'category': fetchedCategory,
            }, SetOptions(merge: true));
      } catch (_) {
      } finally {
        _categoryBackfillInFlight.remove(productId);
      }
    }
  }

  Map<String, dynamic> _toWishlistItem(Map<String, dynamic> product) {
    final id = _productId(product);
    final brand = (product['brand'] ?? '').toString();
    final model = (product['model'] ?? '').toString();
    final title = (product['title'] ?? '').toString().trim().isNotEmpty
        ? (product['title'] ?? '').toString()
        : '$brand $model'.trim();

    String image = (product['image'] ?? '').toString().trim();
    if (image.isEmpty) {
      final rawImageUrls = product['imageUrls'] ?? product['images'];
      if (rawImageUrls is List && rawImageUrls.isNotEmpty) {
        final first = rawImageUrls.first;
        if (first is String) image = first;
      }
    }
    if (image.isEmpty) {
      image = (product['imageUrl'] ?? '').toString();
    }

    final specs = _buildSpecs(product);

    final priceString = _formatMoney(product['price']);
    final originalPriceRaw = product['originalPrice'];
    final originalPriceString = originalPriceRaw == null
        ? null
        : _formatMoney(originalPriceRaw);
    final onSale =
        originalPriceString != null && originalPriceString != priceString;

    final category = (product['category'] ?? '').toString().trim();

    return <String, dynamic>{
      'id': id,
      'title': title,
      'specs': specs,
      'category': category,
      'price': priceString,
      'image': image,
      'onSale': onSale,
      if (originalPriceString != null) 'originalPrice': originalPriceString,
    };
  }

  String _productId(Map<String, dynamic> product) {
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

  String _buildSpecs(Map<String, dynamic> product) {
    final specs = product['specifications'];
    if (specs is Map) {
      final cpu = (specs['cpu'] ?? '').toString().trim();
      final ram = (specs['ram'] ?? '').toString().trim();
      final storage = (specs['storage'] ?? '').toString().trim();
      final parts = [cpu, ram, storage].where((e) => e.isNotEmpty).toList();
      if (parts.isNotEmpty) return parts.take(2).join(' | ');
    }

    final category = (product['category'] ?? '').toString().trim();
    return category.isNotEmpty ? category : 'Item';
  }

  String _formatMoney(dynamic value) {
    if (value == null) return '\$0.00';
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.startsWith('\$')) return trimmed;
      final parsed = double.tryParse(trimmed);
      if (parsed != null) return '\$${parsed.toStringAsFixed(2)}';
      return '\$0.00';
    }
    if (value is num) return '\$${value.toDouble().toStringAsFixed(2)}';
    return '\$0.00';
  }

  @override
  void dispose() {
    _wishlistSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
