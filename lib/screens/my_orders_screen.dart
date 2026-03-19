import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_back_button.dart';
import 'order_details_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _statusFromCreatedAt(DateTime createdAt) {
    final today = DateTime.now();
    final day0 = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final dayNow = DateTime(today.year, today.month, today.day);
    final diffDays = dayNow.difference(day0).inDays;
    if (diffDays <= 0) return 'IN TRANSIT';
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
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.slate900,
          unselectedLabelColor: Colors.grey[400],
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(filter: 'All'),
          _buildOrdersList(filter: 'Active'),
          _buildOrdersList(filter: 'Completed'),
          _buildOrdersList(filter: 'Cancelled'),
        ],
      ),
    );
  }

  Widget _buildOrdersList({required String filter}) {
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
          final derivedStatus = _statusFromCreatedAt(createdAt);
          final status = (data['status'] ?? derivedStatus)
              .toString()
              .toUpperCase();
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
            price: '₦${total.toDouble().toStringAsFixed(2)}',
            isGrayscale: status == 'CANCELLED',
          );
        }).toList();

        final filtered = filter == 'All'
            ? orders
            : filter == 'Active'
            ? orders
                  .where(
                    (o) => o.status != 'DELIVERED' && o.status != 'CANCELLED',
                  )
                  .toList()
            : filter == 'Completed'
            ? orders.where((o) => o.status == 'DELIVERED').toList()
            : orders.where((o) => o.status == 'CANCELLED').toList();

        if (filtered.isEmpty) {
          return Center(
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
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) =>
              _buildOrderCard(context, filtered[index]),
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
