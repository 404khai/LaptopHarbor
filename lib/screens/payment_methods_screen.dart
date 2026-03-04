import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_back_button.dart';
import 'payment_processing_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // Mock data for payment methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'visa',
      'type': 'Visa',
      'number': '•••• 4242',
      'expiry': 'Expires 12/26',
      'isDefault': true,
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDIVmFCNDQGWCXavXJfqN4YKuX2DHMVxP1FLwvlf700dOOTuee0_KbbqQoin_9qKAgvV14Iet5DkpHI6BOVmllo1A7TrLIlaHCsezG4A-6K8mL6yH9S6l9vpAvAnEuhDCLfK_Zq5CX7fiTy2fzRP8SoINQAqzs6Q3uJrU0z3wD7Wuaut6AiJ6KgbSoLitktWz8H5SPPq6mVRXyQo18SIU8WfUA1T9oqhmjrrXLfiBWEYvkrGPJSWVxZbdgZSFzw9HCfoiKWzLmy4XT_',
    },
    {
      'id': 'mastercard',
      'type': 'Mastercard',
      'number': '•••• 8899',
      'expiry': 'Expires 09/25',
      'isDefault': false,
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBnw56Q27M6boX2QXWzV_Q1ar7S_UY4Hn0NLLToPwcFHbNH8Wz5ybxTmdoPlH5hRKev3jMgZztFEfZTPb2y2UfdMMgmfW86LaY6ao_1GYv3z4QkX8Ej-IrVaFQPNOQxLmrp-RIDeSe7pmO4qZrXKalDt3R4SHblBnYlTF-liAVocOghkfSPyoLtcs7SErd7dxSWyriRD1bQCNi66aF3-My7LTPzqZDG4khzKgbM84c0zc8mYbpWHT1c2M8KqoNxaEUS_Tad8U1nNEK6',
    },
    {
      'id': 'apple_pay',
      'type': 'Apple Pay',
      'subtitle': 'Quick checkout enabled',
      'isActive': false,
      'isWallet': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: const Center(child: CustomBackButton()),
        title: Text(
          'Payment Methods',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.slate900,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(0, 36),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Add New',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                      'SAVED CARDS',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your preferred payment options for faster checkout.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[400],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._paymentMethods.map(
                      (method) => _buildPaymentCard(method),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info,
                            color: AppColors.slate900,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your payment information is encrypted and securely stored. We never share your full card details.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentProcessingScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.slate900,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Confirm & Pay',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> method) {
    bool isWallet = method['isWallet'] == true;
    bool isActive = isWallet
        ? (method['isActive'] ?? false)
        : (method['isDefault'] ?? false);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Center(
                  child: isWallet
                      ? const Icon(
                          Icons.account_balance_wallet,
                          color: AppColors.slate900,
                          size: 20,
                        )
                      : Image.network(
                          method['image'],
                          width: 32,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.credit_card, size: 20),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isWallet
                          ? method['type']
                          : '${method['type']} ${method['number']}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isWallet ? method['subtitle'] : method['expiry'],
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_vert, color: Colors.grey[400]),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)), // slate-100
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isWallet ? 'Active' : 'Set as Default',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Switch.adaptive(
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    if (isWallet) {
                      method['isActive'] = value;
                    } else {
                      // If setting as default, unset others (simplified logic)
                      if (value) {
                        for (var m in _paymentMethods) {
                          if (m['isWallet'] != true) {
                            m['isDefault'] = false;
                          }
                        }
                        method['isDefault'] = true;
                      } else {
                        method['isDefault'] = false;
                      }
                    }
                  });
                },
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey[200],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
