import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

class CartProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> get cartItems => _cartItems;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CartProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _fetchCart();
      } else {
        _cartItems = [];
        notifyListeners();
      }
    });
  }

  void _fetchCart() {
    _firebaseService.getCart().listen((snapshot) {
      _cartItems = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
      notifyListeners();
    });
  }

  Future<void> addToCart(Product product, int quantity) async {
    _isLoading = true;
    notifyListeners();
    
    await _firebaseService.addToCart(product, quantity);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int change) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cartRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId);

    await cartRef.update({
      'quantity': FieldValue.increment(change),
    });
  }

  Future<void> removeFromCart(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) {
      final price = (item['price'] ?? 0).toDouble();
      final quantity = (item['quantity'] ?? 0) as int;
      return sum + (price * quantity);
    });
  }
}
