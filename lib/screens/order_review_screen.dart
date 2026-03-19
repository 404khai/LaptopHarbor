import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_back_button.dart';
import '../providers/cart_provider.dart';
import 'order_confirmation_screen.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderReviewScreen extends StatefulWidget {
  final String? selectedAddressId;

  const OrderReviewScreen({super.key, this.selectedAddressId});

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  bool _isTermsAccepted = false;
  bool _isShippingExpanded = true;
  bool _isPaymentExpanded = false;
  bool _isItemsExpanded = true;
  bool _isPlacingOrder = false;

  String _formatMoney(double amount) {
    return '₦${amount.toStringAsFixed(2)}';
  }

  String _formatAddress(Map<String, dynamic> data) {
    final label = (data['label'] ?? 'Address').toString().trim();
    final city = (data['city'] ?? '').toString().trim();
    final state = (data['state'] ?? '').toString().trim();
    final country = (data['country'] ?? '').toString().trim();
    final zip = (data['zipCode'] ?? '').toString().trim();

    final line2 = [city, state].where((p) => p.isNotEmpty).join(', ');
    final line3 = [country, zip].where((p) => p.isNotEmpty).join(' ');
    return [label, line2, line3].where((p) => p.isNotEmpty).join('\n');
  }

  Future<String?> _resolveAddressId(String uid) async {
    final selected = widget.selectedAddressId?.trim();
    if (selected != null && selected.isNotEmpty) return selected;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .orderBy('createdAt', descending: true)
        .get();
    if (snapshot.docs.isEmpty) return null;

    final defaults = snapshot.docs.where(
      (d) => (d.data()['isDefault'] ?? false) == true,
    );
    if (defaults.isNotEmpty) return defaults.first.id;
    return snapshot.docs.first.id;
  }

  Future<Map<String, dynamic>?> _loadAddress({
    required String uid,
    required String addressId,
  }) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc(addressId)
        .get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return <String, dynamic>{...data, 'id': doc.id};
  }

  String _derivedStatus(DateTime createdAt) {
    final today = DateTime.now();
    final day0 = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final dayNow = DateTime(today.year, today.month, today.day);
    final diffDays = dayNow.difference(day0).inDays;
    if (diffDays <= 0) return 'processing';
    if (diffDays == 1) return 'shipped';
    if (diffDays == 2) return 'in_transit';
    return 'delivered';
  }

  Future<String> _createOrder({
    required String uid,
    required String orderNumber,
    required String paystackReference,
    required String currency,
    required double subtotal,
    required double shippingCost,
    required double tax,
    required double total,
    required List<Map<String, dynamic>> cartItems,
  }) async {
    final now = DateTime.now();
    final addressId = await _resolveAddressId(uid);
    final address = addressId == null
        ? null
        : await _loadAddress(uid: uid, addressId: addressId);

    final items = cartItems.map((item) {
      final quantity = (item['quantity'] is num)
          ? (item['quantity'] as num).toInt()
          : 1;
      final price = (item['price'] is num)
          ? (item['price'] as num).toDouble()
          : 0.0;
      return <String, dynamic>{
        'productId': (item['productId'] ?? item['id'] ?? '').toString(),
        'name': (item['name'] ?? 'Item').toString(),
        'image': (item['image'] ?? '').toString(),
        'quantity': quantity,
        'unitPrice': price,
        'lineTotal': price * quantity,
      };
    }).toList();

    final orderData = <String, dynamic>{
      'orderNumber': orderNumber,
      'paystackReference': paystackReference,
      'currency': currency,
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'tax': tax,
      'total': total,
      'items': items,
      'shippingAddressId': addressId,
      'shippingAddress': address,
      'status': _derivedStatus(now),
      'estimatedDeliveryStart': Timestamp.fromDate(now),
      'estimatedDeliveryEnd': Timestamp.fromDate(
        now.add(const Duration(days: 3)),
      ),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('orders')
        .add(orderData);
    return docRef.id;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final subtotal = cart.totalAmount;
    const shippingCost = 0.0;
    const tax = 0.0;
    final total = subtotal + shippingCost + tax;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const Center(child: CustomBackButton()),
        title: Text(
          'Order Review',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Review Order',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  Text(
                    'Step 4 of 4',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress Bar
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'SHIPPING → PAYMENT → REVIEW',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),

              // Shipping Address Section
              _buildCollapsibleSection(
                title: 'Shipping Address',
                icon: Icons.local_shipping_outlined,
                isExpanded: _isShippingExpanded,
                onTap: () {
                  setState(() {
                    _isShippingExpanded = !_isShippingExpanded;
                  });
                },
                child: (() {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) {
                    return Text(
                      'Please sign in to view shipping address.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    );
                  }

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('addresses')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? const [];
                      if (docs.isEmpty) {
                        return Text(
                          'No saved address selected.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        );
                      }

                      QueryDocumentSnapshot<Map<String, dynamic>> selected =
                          docs.first;

                      if (widget.selectedAddressId != null) {
                        final match = docs.where(
                          (d) => d.id == widget.selectedAddressId,
                        );
                        if (match.isNotEmpty) {
                          selected = match.first;
                        }
                      } else {
                        final defaults = docs.where(
                          (d) => (d.data()['isDefault'] ?? false) == true,
                        );
                        if (defaults.isNotEmpty) {
                          selected = defaults.first;
                        }
                      }

                      return Text(
                        _formatAddress(selected.data()),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      );
                    },
                  );
                })(),
              ),
              const SizedBox(height: 16),

              // Payment Method Section
              _buildCollapsibleSection(
                title: 'Payment Method',
                icon: Icons.credit_card,
                isExpanded: _isPaymentExpanded,
                onTap: () {
                  setState(() {
                    _isPaymentExpanded = !_isPaymentExpanded;
                  });
                },
                child: Text(
                  'Credit Card ending in 4242\nExp: 12/26',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Order Items Section
              _buildCollapsibleSection(
                title: 'Order Items',
                icon: Icons.shopping_bag_outlined,
                isExpanded: _isItemsExpanded,
                onTap: () {
                  setState(() {
                    _isItemsExpanded = !_isItemsExpanded;
                  });
                },
                child: cart.cartItems.isEmpty
                    ? Text(
                        'Your cart is empty.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      )
                    : Column(
                        children: [
                          for (final item in cart.cartItems) ...[
                            _buildOrderItem(
                              title: (item['name'] ?? 'Item').toString(),
                              quantity: (item['quantity'] is num)
                                  ? (item['quantity'] as num).toInt()
                                  : 1,
                              price: _formatMoney(
                                ((item['price'] is num)
                                        ? (item['price'] as num).toDouble()
                                        : 0.0) *
                                    ((item['quantity'] is num)
                                        ? (item['quantity'] as num).toDouble()
                                        : 1.0),
                              ),
                              imageUrl: (item['image'] ?? '').toString(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: 32),

              // Price Breakdown
              _buildSummaryRow('Subtotal', _formatMoney(subtotal)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shipping',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    shippingCost == 0 ? 'FREE' : _formatMoney(shippingCost),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSummaryRow('Tax', _formatMoney(tax)),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE2E8F0)), // Slate-200
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                  Text(
                    _formatMoney(total),
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.slate900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Terms and Place Order
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _isTermsAccepted,
                      onChanged: (value) {
                        setState(() {
                          _isTermsAccepted = value ?? false;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(
                        color: AppColors.slate900,
                        width: 2,
                      ),
                      activeColor: AppColors.slate900,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              color: AppColors.slate900,
                            ),
                          ),
                          const TextSpan(
                            text:
                                ' and authorize LaptopHarbor to process this payment.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    if (_isPlacingOrder) return;
                    if (!_isTermsAccepted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Please accept terms and conditions.'),
                        ),
                      );
                      return;
                    }
                    if (cart.cartItems.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Your cart is empty.')),
                      );
                      return;
                    }

                    final email =
                        FirebaseAuth.instance.currentUser?.email ??
                        'customer@example.com';
                    final reference =
                        'LH-${DateTime.now().millisecondsSinceEpoch}';
                    final computedKobo = (total * 100).round();
                    final amountKobo = (computedKobo < 100 ? 100 : computedKobo)
                        .toString();

                    final secretKey = (dotenv.env['PAYSTACK_SECRET_KEY'] ?? '')
                        .trim();
                    final callbackUrl =
                        (dotenv.env['PAYSTACK_CALLBACK_URL'] ?? '').trim();

                    if (secretKey.isEmpty || callbackUrl.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Missing Paystack credentials. Please set PAYSTACK_SECRET_KEY and PAYSTACK_CALLBACK_URL.',
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      final cartItemsSnapshot = List<Map<String, dynamic>>.from(
                        cart.cartItems,
                      );
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Please sign in first.'),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        _isPlacingOrder = true;
                      });

                      await FlutterPaystackPlus.openPaystackPopup(
                        context: context,
                        customerEmail: email,
                        amount: amountKobo,
                        reference: reference,
                        secretKey: secretKey,
                        callBackUrl: callbackUrl,
                        currency: 'NGN',
                        onSuccess: () {
                          final cartProvider = context.read<CartProvider>();
                          final navigator = Navigator.of(context);
                          Future<void>.microtask(() async {
                            if (!mounted) return;
                            try {
                              final orderId = await _createOrder(
                                uid: uid,
                                orderNumber: reference,
                                paystackReference: reference,
                                currency: 'NGN',
                                subtotal: subtotal,
                                shippingCost: shippingCost,
                                tax: tax,
                                total: total,
                                cartItems: cartItemsSnapshot,
                              );
                              await cartProvider.clearCart();
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Payment successful!'),
                                ),
                              );
                              navigator.pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrderConfirmationScreen(orderId: orderId),
                                ),
                              );
                            } catch (_) {
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to place order.'),
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isPlacingOrder = false;
                                });
                              }
                            }
                          });
                        },
                        onClosed: () {
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Payment cancelled or failed.'),
                            ),
                          );
                          setState(() {
                            _isPlacingOrder = false;
                          });
                        },
                      );
                    } catch (_) {
                      if (!mounted) return;
                      setState(() {
                        _isPlacingOrder = false;
                      });
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Failed to start Paystack checkout.'),
                        ),
                      );
                    }
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
                      Text(
                        _isPlacingOrder ? 'Processing...' : 'Make Payment',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: isExpanded ? Radius.zero : const Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.slate900),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate900,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(
                    height: 1,
                    color: Color(0xFFF1F5F9),
                  ), // slate-100
                  const SizedBox(height: 16),
                  child,
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItem({
    required String title,
    required int quantity,
    required String price,
    required String imageUrl,
  }) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
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
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Qty: $quantity',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
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
    );
  }
}
