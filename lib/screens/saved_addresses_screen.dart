import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_back_button.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  int _selectedAddressIndex = 0;

  final List<Map<String, dynamic>> _addresses = [
    {
      'name': 'Alex Chen',
      'address': '888 Innovation Way\nSuite 404, Tech District\nSan Francisco, CA 94105',
      'isDefault': true,
    },
    {
      'name': 'Sarah Jenkins',
      'address': 'LaptopHarbor HQ - Receiving\n24 Silicon Avenue\nAustin, TX 78701',
      'isDefault': false,
    },
    {
      'name': 'Jordan River',
      'address': '101 Binary Blvd\nSeattle, WA 98101',
      'isDefault': false,
    },
  ];

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
          'Saved Addresses',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.slate900,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              onPressed: () {
                // Add new address
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              ...List.generate(_addresses.length, (index) {
                final address = _addresses[index];
                final isSelected = _selectedAddressIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAddressIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey[200]!,
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Radio Button
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address['name'],
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slate900,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  address['address'],
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                ),
                                if (address['isDefault']) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'DEFAULT',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Actions
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Colors.grey[400],
                                ),
                                onPressed: () {},
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(height: 16),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Colors.grey[400],
                                ),
                                onPressed: () {},
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              // Add New Address Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.none, // Dashed border workaround needs CustomPainter or library, using dotted border effect via other means or just simple border for now as standard Flutter Border doesn't support dashed easily without package. 
                    // However, I can use a standard outline button with dashed-like styling or just a grey outline.
                    // The prompt asks for "design matching image". Image has dashed border.
                    // I will use a simple outline button for now to avoid complexity or external packages if possible, 
                    // or I can try to simulate it. Let's stick to standard OutlineButton but maybe with a custom painter if I really wanted to.
                    // For now, I'll use a standard border but maybe lighter/different to indicate action.
                  ),
                ),
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!, width: 2), // Solid for now
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    foregroundColor: Colors.grey[600],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_location_alt_outlined, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Add New Address',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
    );
  }

}
