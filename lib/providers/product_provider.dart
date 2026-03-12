import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/techspecs_service.dart';

class ProductProvider with ChangeNotifier {
  final TechSpecsService _techSpecsService = TechSpecsService();

  List<Product> _products = [];
  List<Product> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchProducts(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      try {
        _products = await _techSpecsService.searchLaptops(query);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('TechSpecs API failed: $e');
        }

        _products = [];
        _error =
            'Failed to fetch products from TechSpecs. Please check API Key.';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> seedTestProducts() async {
    _products = [
      Product(
        id: '1',
        brand: 'Apple',
        model: 'MacBook Pro M3',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDlTmJfoewKdiDVkNFs1GlPFV4WfErPhGDK670DxPDzF40qOB-30uI81qvZrjGuy_K4OB2auSiAb2oynY4FsWJCwoFaUCNAIzKV_h0SIMS52bpByd0wTgFgvmidsH00vBoBjOaQ2p50hN9iH1xdm5fKa36A66d_Dqkj4v-dF5Rg33kKSMTNAp4_l3bo5EfikPSXfivfnmuxgLt0UEDs3f_vCfs3IlY9YGWs6-mS6QMMtQIWEM2ttGsTXDl3ZCmehBpakyk-2HpusB4g',
        price: 1599.00,
        description: 'Powerful laptop for pros',
        specifications: {'processor': 'M3'},
        category: 'Laptop',
      ),
      Product(
        id: '2',
        brand: 'Dell',
        model: 'XPS 15',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDWicXjiNoU7pZdNZ9WpO8VZLZPnteX_zTRedS0l4UuN3kuu-S-VE4_yvK5aLDkosSvyfePA5rgq8mnYvENwz2_bHxt2xkcVLxgVLJy1_Vv3jvYi4wn2y83GN2TWXxpWNHuHzMlaznQi0lqleByVFtzU6hJF7UzOJa31pwN7XBYkAP38bvZYC2JR-lqZ8XFfXOdUypS4WvvHbf_Gif48Tgg1gIPvg_qom7N2qrB0Z7-F-cFmuClIx2JLU0S1XIWGZE7TqBQOBpKkPNe',
        price: 1399.00,
        description: 'Stunning display',
        specifications: {'processor': 'Intel i9'},
        category: 'Laptop',
      ),
    ];
    notifyListeners();
  }
}
