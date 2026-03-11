import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Products
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Since Product.fromJson expects a map structure matching the API, 
        // we might need to adjust or create a separate fromFirestore factory.
        // For now, let's assume the stored data matches the Product fields directly.
        return Product(
          id: doc.id,
          brand: data['brand'] ?? '',
          model: data['model'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          originalPrice: (data['originalPrice'] ?? 0).toDouble(),
          description: data['description'] ?? '',
          specifications: Map<String, dynamic>.from(data['specifications'] ?? {}),
          category: data['category'] ?? '',
        );
      }).toList();
    });
  }

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).set({
      'brand': product.brand,
      'model': product.model,
      'imageUrl': product.imageUrl,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'description': product.description,
      'specifications': product.specifications,
      'category': product.category,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Cart
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

  // Orders
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
