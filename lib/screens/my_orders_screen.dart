import 'package:flutter/material.dart';
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
    final allOrders = [
      _OrderData(
        id: '#LH-892341',
        status: 'DELIVERED',
        statusColor: AppColors.primary,
        statusTextColor: AppColors.slate900,
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAoK5vBH-MRfZZSeWkhDBqhTHc9G36U9C0cGDtwFpJW4-5A0NHaFUi2GxW0IGnTcgASKwvsgRivqAjg6-hzPcu19gma1se-UhwJsmgW3b55OjVLDAmtPA6Z0Ah3EkbjRW1GLQKxZQKC1e_648O1FEZihJwEhrXD66O6L5yO7h2Bp6Qr2Ll-U045eS1Psx3b4FFcq4cXDP9UR1SC4kaN4tzeRkrtR3LDKgOF2Qt-SCMgKtibDbsQY3AiyGlTrXyzN2HxTStKIfLMnyvH',
        title: 'High-Performance Laptop',
        quantity: '1x',
        date: 'Oct 22, 2024',
        price: '\$1,299.00',
      ),
      _OrderData(
        id: '#LH-892342',
        status: 'IN TRANSIT',
        statusColor: AppColors.primary.withOpacity(0.2),
        statusTextColor: AppColors.slate900,
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDotNpGa1LstRfj4smJ3zVMIkIDZQTMPZOXgdGySc1sweFP_LByMbSUk0MyYTfeQuUoFSKk7lZiy9bQabzKxjXwkX-9WC3hE6exqboNIYUXLVgDg2Sf2swYBRNGPBVsj_oGIa_IrZaPx56FU3Gv4Ahlq5GWXVK_xol1zNhHO8bB2gZ20W20vXXE6aVPwgyt7rooTBOcT-22esOP5A2xMJORf7IBtiLsTFpydRv8CKHcnb6JrZvHhQeQ7MhU8Ii7jw6uNHMutyfdtR09',
        title: 'Wireless Gaming Mouse',
        quantity: '1x',
        date: 'Oct 21, 2024',
        price: '\$89.00',
      ),
      _OrderData(
        id: '#LH-892339',
        status: 'CANCELLED',
        statusColor: Colors.grey[100]!,
        statusTextColor: Colors.grey[500]!,
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAiTXQKrHZ1nOyRQU0CTJpt9uIgOcRa7IivQIDFGjPPiDF6CiyVYBKeCh29bp9ZjHxZWUUm4jSji9WOiMTXjS-4ob1s125hw_-uitcKWhGQnaIKIVUqn-wJyLkb8okFi9D8ycYZcMlm9sCh09eVLzskpsYP99H-Mns7lUvl1f4z74Gec_nntuFJcekHXAAR8Sj0TlLlQDKWSvIsYA2nJD4HElRwGR6ohTXdAZBP3iMM2GUpS9Szxhh63vn6w4wucq77L98sdCWU-swQ',
        title: 'Pro Tablet Gen 5',
        quantity: '1x',
        date: 'Oct 18, 2024',
        price: '\$799.00',
        isGrayscale: true,
      ),
    ];

    List<_OrderData> filteredOrders;
    if (filter == 'All') {
      filteredOrders = allOrders;
    } else if (filter == 'Active') {
      filteredOrders = allOrders
          .where((o) => o.status == 'IN TRANSIT')
          .toList();
    } else if (filter == 'Completed') {
      filteredOrders = allOrders.where((o) => o.status == 'DELIVERED').toList();
    } else {
      filteredOrders = allOrders.where((o) => o.status == 'CANCELLED').toList();
    }

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
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
      itemCount: filteredOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) =>
          _buildOrderCard(context, filteredOrders[index]),
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
            color: Colors.black.withOpacity(0.05),
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
                        builder: (context) => const OrderDetailsScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.2),
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
