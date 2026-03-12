import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_back_button.dart';
import 'order_details_screen.dart';
import 'package_tracking_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const Center(child: CustomBackButton()),
        title: Text(
          'Order Status',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Success Icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Order Confirmed!',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Your order '),
                      TextSpan(
                        text: '#LH-892341',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' has been placed successfully. We\'ll notify you once it ships.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Map/Delivery Card
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDPfZczVSKuQa2gHCNHm2qr8JJDz_GlADs-YosG0rbg7UUPecIUH_T5WE9gtvrHroiTgVoT4V9EiIhMZ0LOmnvcaohLuJ9YChIkC3nhKzuJEFm4b01OYkM4WesuUgCs-QsQN4TKuIIx7Qn_fyLCNhPIWVQRJu6x7i2eItKkQfKjvc1dGxK05r69HHDUvKzM9pv4nj3upOr7Njbwya0xT7JLDTADtBvevB4Uvejahw6rsSwlGgeO_ytodcvLbH2_baZHqwu3iL_cXqQC',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTIMATED DELIVERY',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Oct 24 - Oct 26',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Item Details Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderDetailsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ITEM DETAILS',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'High-Performance Laptop',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '1x - \$1,299.00',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 80,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBAowkvZXZcuE13G-EE1gajlHFAN1aPvliVsr2sSkUwcCd3OVELHZ6jCbc0K48h0AeU1Rr6Ile_lhltJgg9PQ5NKGB1BiPv2diBTuByZhoMU8DHnAAoyYZDBwbHgTPbqHUbxYqAnabwEzaDGq1jZ9vfIjHh2mBW-fTdEr1rk-mZp0bkpTh2n7UjjHeckC12W48OlBEn2-U8_Rp0xJAJkxjp7dMEkovgyJDebVDcniKqlu45aJaK3gIg7YxQ227tKezBTo7aJh2b7O74',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PackageTrackingScreen(),
                      ),
                    );
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
                      const Icon(Icons.local_shipping, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Track Order',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.slate900, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Continue Shopping',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Footer Info
              _buildFooterInfo(
                Icons.mail_outline,
                'Confirmation sent to ',
                'alex@example.com',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help_outline, color: Colors.grey[400], size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Need help? ',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Contact Support',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterInfo(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(width: 12),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
            children: [
              TextSpan(text: label),
              TextSpan(
                text: value,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
