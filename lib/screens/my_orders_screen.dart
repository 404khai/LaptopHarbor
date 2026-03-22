import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_back_button.dart';
import 'order_details_screen.dart';
import '../utils/money.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  int _selectedFilterIndex = 0;
  static const List<String> _filters = [
    'All',
    'Active',
    'Completed',
    'Cancelled',
  ];

  String _normalizeStatus({
    required dynamic rawStatus,
    required DateTime createdAt,
  }) {
    final fallback = _derivedStatus(createdAt: createdAt);
    if (rawStatus is! String) return fallback;
    final normalized = rawStatus
        .trim()
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');

    if (normalized == 'cancelled' || normalized == 'canceled') {
      return 'CANCELLED';
    }
    if (normalized == 'delivered') return 'DELIVERED';
    if (normalized == 'shipped') return 'SHIPPED';
    if (normalized == 'in_transit' || normalized == 'intransit') {
      return 'IN TRANSIT';
    }
    if (normalized == 'processing') return 'PROCESSING';
    return fallback;
  }

  String _derivedStatus({required DateTime createdAt}) {
    final today = DateTime.now();
    final day0 = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final dayNow = DateTime(today.year, today.month, today.day);
    final diffDays = dayNow.difference(day0).inDays;
    if (diffDays <= 0) return 'PROCESSING';
    if (diffDays == 1) return 'SHIPPED';
    if (diffDays == 2) return 'IN TRANSIT';
    return 'DELIVERED';
  }

  String _formatDate(DateTime dt) {
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
    return '$m ${dt.day}, ${dt.year}';
  }

  Color _statusColor(String status) {
    if (status == 'DELIVERED') return AppColors.primary;
    if (status == 'CANCELLED') return Colors.grey[100]!;
    return AppColors.primary.withValues(alpha: 0.2);
  }

  Color _statusTextColor(String status) {
    if (status == 'CANCELLED') return Colors.grey[500]!;
    return AppColors.slate900;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Center(child: CustomBackButton()),
        centerTitle: false,
        title: Text(
          'My Orders',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.slate900),
          ),
        ],
      ),
      body: _buildOrdersList(),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0F172A) : Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.text,
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Center(
        child: Text(
          'Please sign in to view orders.',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.slate900,
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? const [];
        final orders = docs.map((d) {
          final data = d.data();
          final createdAtTs = data['createdAt'];
          final createdAt = (createdAtTs is Timestamp)
              ? createdAtTs.toDate()
              : DateTime.now();
          final status = _normalizeStatus(
            rawStatus: data['status'],
            createdAt: createdAt,
          );
          final itemsRaw = data['items'];
          final items = (itemsRaw is List) ? itemsRaw : const [];
          final firstItem = items.isNotEmpty && items.first is Map
              ? (items.first as Map)
              : null;
          final title = (firstItem?['name'] ?? 'Order').toString();
          final image = (firstItem?['image'] ?? '').toString();
          final quantity = items.fold<int>(0, (totalQty, e) {
            if (e is Map && e['quantity'] is num) {
              return totalQty + (e['quantity'] as num).toInt();
            }
            return totalQty;
          });
          final total = (data['total'] is num) ? data['total'] as num : 0;
          final orderNumber = (data['orderNumber'] ?? '').toString().trim();
          return _OrderData(
            docId: d.id,
            id: orderNumber.isEmpty ? 'Order' : orderNumber,
            status: status,
            statusColor: _statusColor(status),
            statusTextColor: _statusTextColor(status),
            image: image,
            title: title,
            quantity: '${quantity}x',
            date: _formatDate(createdAt),
            price: Money.ngn(total),
            isGrayscale: status == 'CANCELLED',
          );
        }).toList();

        final allCount = orders.length;
        final activeCount = orders
            .where((o) => o.status != 'DELIVERED' && o.status != 'CANCELLED')
            .length;
        final completedCount = orders
            .where((o) => o.status == 'DELIVERED')
            .length;
        final cancelledCount = orders
            .where((o) => o.status == 'CANCELLED')
            .length;

        final selected = _filters[_selectedFilterIndex];
        final filtered = selected == 'All'
            ? orders
            : selected == 'Active'
            ? orders
                  .where(
                    (o) => o.status != 'DELIVERED' && o.status != 'CANCELLED',
                  )
                  .toList()
            : selected == 'Completed'
            ? orders.where((o) => o.status == 'DELIVERED').toList()
            : orders.where((o) => o.status == 'CANCELLED').toList();

        final chips = <String>[
          'All ($allCount)',
          'Active ($activeCount)',
          'Completed ($completedCount)',
          'Cancelled ($cancelledCount)',
        ];

        return Column(
          children: [
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(chips.length, (index) {
                  final isSelected = _selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilterIndex = index;
                        });
                      },
                      child: _buildCategoryChip(
                        chips[index],
                        isSelected: isSelected,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders found',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) =>
                          _buildOrderCard(context, filtered[index]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, _OrderData order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.id,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: order.statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: order.statusTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(order.image),
                    fit: BoxFit.cover,
                    colorFilter: order.isGrayscale
                        ? const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantity: ${order.quantity}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      order.date,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Footer
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PRICE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                    Text(
                      order.price,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderDetailsScreen(orderId: order.docId),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'View Details',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderData {
  final String docId;
  final String id;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final String image;
  final String title;
  final String quantity;
  final String date;
  final String price;
  final bool isGrayscale;

  _OrderData({
    required this.docId,
    required this.id,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.image,
    required this.title,
    required this.quantity,
    required this.date,
    required this.price,
    this.isGrayscale = false,
  });
}
