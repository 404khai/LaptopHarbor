import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_back_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const Center(child: CustomBackButton()),
        title: Text(
          'Search',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search for your next laptop...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                      onPressed: () => _searchController.clear(),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recent Searches
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RECENT SEARCHES',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.subtext,
                            letterSpacing: 0.5,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Clear All',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildRecentSearchChip('MacBook Pro'),
                        _buildRecentSearchChip('Gaming Laptops'),
                        _buildRecentSearchChip('Dell XPS'),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Suggestions
                    Text(
                      'SUGGESTIONS',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.subtext,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSuggestionItem(
                      'Apple MacBook Pro 14" M3',
                      '\$1,599.00',
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBHZloT4uoJ5qEyy27P4jjeXRGJIZtblE0_4s_9D1QMj_qy8csCyqPK3H0fC2DAU4PYZV8xTGElI535hgIqt9t-j4-jTxvrpbZYOmjM8u4sCdyraHcM4SYSOTSKVBsZX27tCtpb9SMNqZ_cl7Om3ehjEG2i8_fMAv6TqDlIejRncPjmnv1K00bknd_Bwzdd6SufC0UFjCC6UDjB4KAAKaNyfBXQvRfRqJ4PFRrvlvhcVGion4Irzuq3R3nbZ05_9SQITRWzJlvVoLJ_',
                    ),
                    _buildSuggestionItem(
                      'Razer Blade 16 Gaming Laptop',
                      '\$2,999.99',
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBLHYlWGKzDb7WltqSsPMrEC4AVTPfK8bpUoUK-9ptmBD8Kq5RgwhyDMaB0r5epFNhnVgpkGH7oWyA7yiv-1_3J62pPSUw3zQmTFFNYAVDIaKuwWzUqaYCfVGO8wJF8ccUeQTPpGyGMb_uiuITYC4dmjv9cf8rW8t3gttUHHB_Sg__3m4A_xuzSMOe-sCwESTeIoIYGnlsNiZ5YjyTwfiJs48Mq_UswRnYch-pLAVzwET7vhy0wbbKl-z0FXLYXBkZF1QIoWzwY1FGI',
                    ),
                    _buildSuggestionItem(
                      'Dell XPS 13 Plus 9320',
                      '\$1,249.00',
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBrmW127igLS55Y9Pl734zl9rbw3Cxxeaoha68McyxNykSrt3eEpghd_zyyAIbry--n1QOw-sjLKPEVNtTv8S8f43aBu86ga2-xvMGIHEW5Xxb-i_kwwwMW3XW6AbmHEvUWE6VesGaSES7nXClXfNYIi1sjHJLHTybT1CUYqlNuOnu03H56lUdCU1kd85Y0pgiHOjFDBlltpdiX1jxFeJLk4sSHm8LhyQlNPLZPIttKHQbvybuFMzxzuYmfPGF6GyZo6WRdS8mg-ZRQ',
                    ),
                    _buildSuggestionItem(
                      'Microsoft Surface Laptop 5',
                      '\$999.00',
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBmoPaT-qMZvHLWT_MJf8dfFEnueN_RA82xol-GzSaYvdk59Xux-Rmx4hzZoCephjSAsC7FLYPTQLktaH0RNhfsHsMUPzzRj_m5rXu-MTIXVXgRl53Uwhjt-VFOdJ8eD8r_5miVG6X_wzNJ5v5frZG1tPhBq2nJNwpEabJNAsCvXxCrby_S7_OE0RIbtYe7ir_dnIVTwSgL2ebRalLHGN5gvH6bYVQGV6yj98MSKY1LdQsvR590-Nqzt-z4fWURDoyCmNFG5YBhE_vj',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String title, String price, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, color: Colors.grey),
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
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  price,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.north_west,
            color: Color(0xFFCBD5E1), // Slate-300
            size: 20,
          ),
        ],
      ),
    );
  }
}
