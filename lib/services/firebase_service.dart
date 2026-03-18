import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        double? originalPrice;
        final originalPriceRaw = data['originalPrice'];
        if (originalPriceRaw is num) {
          originalPrice = originalPriceRaw.toDouble();
        } else if (originalPriceRaw is String) {
          originalPrice = double.tryParse(originalPriceRaw);
        }

        final imageUrls = <String>[];
        final rawImageUrls = data['imageUrls'];
        if (rawImageUrls is List) {
          for (final item in rawImageUrls) {
            if (item is String && item.trim().isNotEmpty) {
              imageUrls.add(item.trim());
            }
          }
        }

        return Product(
          id: doc.id,
          brand: data['brand'] ?? '',
          model: data['model'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
          price: (data['price'] ?? 0).toDouble(),
          originalPrice: originalPrice,
          description: data['description'] ?? '',
          specifications: Map<String, dynamic>.from(data['specifications'] ?? {}),
          category: data['category'] ?? '',
          rating: (data['rating'] ?? 0).toDouble(),
          reviewCount: (data['reviewCount'] ?? 0) is num
              ? (data['reviewCount'] as num).toInt()
              : 0,
          inStock: data['inStock'] == true,
          stock: (data['stock'] ?? 0) is num ? (data['stock'] as num).toInt() : 0,
        );
      }).toList();
    });
  }

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).set({
      'brand': product.brand,
      'model': product.model,
      'imageUrl': product.imageUrl,
      'imageUrls': product.imageUrls,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'description': product.description,
      'specifications': product.specifications,
      'category': product.category,
      'rating': product.rating,
      'reviewCount': product.reviewCount,
      'inStock': product.inStock,
      'stock': product.stock,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addToCart(Product product, int quantity) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cartRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(product.id);

    final doc = await cartRef.get();
    if (doc.exists) {
      await cartRef.update({
        'quantity': FieldValue.increment(quantity),
      });
    } else {
      await cartRef.set({
        'productId': product.id,
        'name': '${product.brand} ${product.model}',
        'price': product.price,
        'image': product.imageUrl,
        'description': product.description,
        'quantity': quantity,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<QuerySnapshot> getCart() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .snapshots();
  }

  Future<void> placeOrder(Map<String, dynamic> orderData) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .add({
      ...orderData,
      'userId': user.uid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
