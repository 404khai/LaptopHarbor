import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'product_details_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_back_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _showResults = false;

  final List<Map<String, String>> _searchResults = [
    {
      'title': 'MacBook Pro 14" - M3 Chip, 16GB RAM',
      'price': '\$1,599.00',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuArdrGaKB57JlBBh-T7YrRv83vrZztTEC5j_0ZZs1phTZLZDOggqB_sU45ZjAElXzKsBJL6V34RfxUrAtUUEf_6HcQ-m93levlWIEQTPX4IsNi1HWZuJkJxiFETqnG6_X2cqsxojuqWjNGhNsG-fTJPalBFziLD-zjW3UcZi6Y21Sq3CpkMKpoHh5dVcIRDmtRw4srUv_gBy0qwDGM7QqHvgU-EdF8_o0omm-bRfkBZESOl4PLeu5FHWMlo68PUoOVcOul7qsMBTQJL',
      'stock': 'IN STOCK',
    },
    {
      'title': 'MacBook Pro 16" - M3 Max, 32GB RAM',
      'price': '\$3,499.00',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAgytkEPvr3PgjqmpGNeovUvSSG_3RgcDfUFWCOjr8embflHQSmldvlH6rwadhyLvPVDZF4LjCxXxF71t6lZgjASL1nVsJdUi5ry-MCBHGorHyrwwMqkXpLY9CeHHqXfb2iAAJtJgmT-l8BGa1tY9sZQ-rpmakwdBvnrkMvu7JSc6UwSR203f-RYKSlqrVu-geKsvdyMA-IHzd7LS9UXOMWcQdI4ATwDa7cRMsiqlFAdA59sZQdhf57yAsXf2qw5zgwz20cXMaucgaa',
      'stock': 'IN STOCK',
    },
    {
      'title': 'MacBook Pro 14" Refurbished - M2 Pro',
      'price': '\$1,299.00',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAvDyKDTlB6hy9dihSmjGj6L-13TwF7p7sgFCLG0MjmUFzRDTPph3lFiOcBqTTvB6aMYrYXyS1iBxeNMpqgjml7pYsq2UGtQhuTIMQjET9XMYDqhHo6Mdq_2YRLUnF30fKCXkNIjHrHKX7S5K1Hw_ppQGaKUdWXrW-CLJpRStr_Tjcz4qQr7JwXxJsMercw-sEhYWsuhDxbV1y_bc7yH13e1wihNkHz-bUXxDbM8dN8vazEk8rUxBwFPVC_sDjuf6xd9i9awkW6IWOJ',
      'stock': 'IN STOCK',
    },
    {
      'title': 'MacBook Pro 14" - M3 Pro, 1TB SSD',
      'price': '\$1,999.00',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBBo_1ZbEvZ-HNOTu4uhTrsAui-2RAiZe2_fM52eQP2eChIb0N7ZDc8kK3BiWhdTP_RRJY4PBnbC6vl9WGe8FD3j3kjGLk1p-89oNdxrQj-z3re5osWhLszzt8jrqJTlhWh0jA2KrJ2yVwty0UWLVe3tRfK-KQdz85TTIgk5EWgB9oTKuHKcZqsRVMYNbS2iwXZRMAcR4RaqD6Tk76RXJgkTu4JO4eNF-QC6ZKLXlUafvs2uwUQfC6Oe4QC9H70rd2o2k30F4yoTG0q',
      'stock': 'IN STOCK',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _showResults = _searchController.text.isNotEmpty;
    });
  }

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '2',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Search laptops...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.cancel,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  style: GoogleFonts.inter(fontSize: 16, color: AppColors.text),
                ),
              ),
            ),

            Expanded(
              child: _showResults
                  ? _buildSearchResults()
                  : _buildRecentAndSuggestions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAndSuggestions() {
    return SingleChildScrollView(
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
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBmoPaT-qMZvHLWT_MJf8dfFEnueN_RA82xol-GzSaYvdk59Xux-Rmx4hzZoCephjSAsC7FLYPTQLktaH0RNhfsHsMUPzzRj_m5rXu-MTIXVXgRl53Uwhjt-VFOdJ8eD8r_5miVG6X_wzNJ5v5frZG1tPhBq2nJNwpEabJNAsC7FLYPTQLktaH0RNhfsHsMUPzzRj_m5rXu-MTIXVXgRl53Uwhjt-VFOdJ8eD8r_5miVG6X_wzNJ5v5frZG1tPhBq2nJNwpEabJNAsCvXxCrby_S7_OE0RIbtYe7ir_dnIVTwSgL2ebRalLHGN5gvH6bYVQGV6yj98MSKY1LdQsvR590-Nqzt-z4fWURDoyCmNFG5YBhE_vj',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '12 results',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.tune, size: 16, color: Colors.grey),
                label: Text(
                  'Filter',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final item = _searchResults[index];
              return _buildResultCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(Map<String, String> item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item['image']!,
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
                    item['stock']!,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['title']!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['price']!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_shopping_cart, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Add to Cart',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
            color: AppColors.slate300, // Slate-300
            size: 20,
          ),
        ],
      ),
    );
  }
}
