import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_back_button.dart';
import 'package_tracking_screen.dart';
import '../utils/money.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  String _formatMoney(num value) {
    return Money.ngn(value);
  }

  String _statusFromCreatedAt(DateTime createdAt) {
    final today = DateTime.now();
    final day0 = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final dayNow = DateTime(today.year, today.month, today.day);
    final diffDays = dayNow.difference(day0).inDays;
    if (diffDays <= 0) return 'processing';
    if (diffDays == 1) return 'shipped';
    if (diffDays == 2) return 'in_transit';
    return 'delivered';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'processing':
        return 'PROCESSING';
      case 'shipped':
        return 'SHIPPED';
      case 'in_transit':
        return 'IN TRANSIT';
      case 'delivered':
        return 'DELIVERED';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDateTime(DateTime dt) {
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
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$m ${dt.day}, ${dt.year} • $hour:$min $ampm';
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

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          leading: const Center(child: CustomBackButton()),
          title: Text(
            'Order Details',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.slate900,
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Text(
              'Please sign in to view order details.',
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

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('orders')
          .doc(widget.orderId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final orderNumber = (data?['orderNumber'] ?? '').toString().trim();
        final createdAtTs = data?['createdAt'];
        final createdAt = (createdAtTs is Timestamp)
            ? createdAtTs.toDate()
            : DateTime.now();
        final status = _statusFromCreatedAt(createdAt);

        if (data != null && (data['status'] ?? '') != status) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('orders')
              .doc(widget.orderId)
              .set(<String, dynamic>{
                'status': status,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
        }

        final itemsRaw = data?['items'];
        final items = (itemsRaw is List) ? itemsRaw : const [];
        final shippingAddress = (data?['shippingAddress'] is Map)
            ? Map<String, dynamic>.from(data?['shippingAddress'] as Map)
            : <String, dynamic>{};
        final subtotal = (data != null && data['subtotal'] is num)
            ? data['subtotal'] as num
            : 0;
        final shippingCost = (data != null && data['shippingCost'] is num)
            ? data['shippingCost'] as num
            : 0;
        final tax = (data != null && data['tax'] is num)
            ? data['tax'] as num
            : 0;
        final total = (data != null && data['total'] is num)
            ? data['total'] as num
            : (subtotal + shippingCost + tax);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            leading: const Center(child: CustomBackButton()),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderNumber.isEmpty ? 'Order' : 'Order $orderNumber',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                Text(
                  'LaptopHarbor Tech Store',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(status),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DELIVERY TIMELINE',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTimeline(createdAt),
                        const SizedBox(height: 32),
                        Text(
                          'PRODUCT INFO',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (items.isEmpty)
                          Text(
                            'No items found.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          )
                        else
                          Column(
                            children: [
                              for (final raw in items)
                                if (raw is Map) ...[
                                  _buildItemCard(
                                    name: (raw['name'] ?? 'Item').toString(),
                                    image: (raw['image'] ?? '').toString(),
                                    quantity: (raw['quantity'] is num)
                                        ? (raw['quantity'] as num).toInt()
                                        : 1,
                                    lineTotal: (raw['lineTotal'] is num)
                                        ? raw['lineTotal'] as num
                                        : 0,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                            ],
                          ),
                        const SizedBox(height: 32),
                        Text(
                          'SHIPPING INFORMATION',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: AppColors.slate900,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  shippingAddress.isEmpty
                                      ? 'No shipping address.'
                                      : _formatAddress(shippingAddress),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'PAYMENT SUMMARY',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(24),
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
                            children: [
                              _buildSummaryRow(
                                'Subtotal',
                                _formatMoney(subtotal),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Shipping',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  Text(
                                    shippingCost == 0
                                        ? 'FREE'
                                        : _formatMoney(shippingCost),
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
                              const Divider(
                                height: 1,
                                color: Color(0xFFF1F5F9),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Amount',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.slate900,
                                    ),
                                  ),
                                  Text(
                                    _formatMoney(total),
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.slate900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PackageTrackingScreen(orderId: widget.orderId),
                          ),
                        );
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
                          const Icon(Icons.local_shipping, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Track Package',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeline(DateTime createdAt) {
    final shippedAt = createdAt.add(const Duration(days: 1));
    final transitAt = createdAt.add(const Duration(days: 2));
    final deliveredAt = createdAt.add(const Duration(days: 3));
    final status = _statusFromCreatedAt(createdAt);

    final isPlaced = true;
    final isShipped =
        status == 'shipped' || status == 'in_transit' || status == 'delivered';
    final isTransit = status == 'in_transit' || status == 'delivered';
    final isDelivered = status == 'delivered';

    return Column(
      children: [
        _buildTimelineItem(
          title: 'Order Placed',
          subtitle: _formatDateTime(createdAt),
          isCompleted: isPlaced,
          isFirst: true,
          icon: Icons.check,
        ),
        _buildTimelineItem(
          title: 'Shipped',
          subtitle: _formatDateTime(shippedAt),
          isCompleted: isShipped,
          icon: Icons.local_shipping,
        ),
        _buildTimelineItem(
          title: 'In Transit',
          subtitle: _formatDateTime(transitAt),
          isCompleted: isTransit,
          isActive: status == 'in_transit',
          icon: Icons.circle,
        ),
        _buildTimelineItem(
          title: 'Delivered',
          subtitle: _formatDateTime(deliveredAt),
          isCompleted: isDelivered,
          isActive: status == 'delivered',
          isLast: true,
          icon: Icons.inventory_2,
        ),
      ],
    );
  }

  Widget _buildItemCard({
    required String name,
    required String image,
    required int quantity,
    required num lineTotal,
  }) {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: image.trim().isEmpty
                ? const SizedBox.shrink()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qty: ${quantity}x',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate900,
                      ),
                    ),
                    Text(
                      _formatMoney(lineTotal),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isActive = false,
    bool isFirst = false,
    bool isLast = false,
    IconData? icon,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: isActive ? 32 : 24,
                  height: isActive ? 32 : 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : (isActive ? Colors.white : Colors.grey[100]),
                    shape: BoxShape.circle,
                    border: isActive
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: isActive
                        ? Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          )
                        : Icon(
                            icon ?? Icons.check,
                            size: 14,
                            color: isCompleted
                                ? AppColors.slate900
                                : Colors.grey[400],
                          ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted ? AppColors.primary : Colors.grey[200],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isActive || isCompleted
                          ? AppColors.slate900
                          : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isActive
                          ? AppColors.slate900
                          : (isCompleted ? Colors.grey[500] : Colors.grey[300]),
                      fontStyle: isActive || isCompleted
                          ? FontStyle.normal
                          : FontStyle.italic,
                      fontWeight: isActive
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
