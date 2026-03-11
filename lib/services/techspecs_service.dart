import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class TechSpecsService {
  final String apiKey = 'YOUR_TECHSPECS_API_KEY'; // Replace with your actual API key
  final String baseUrl = 'https://api.techspecs.io/v4';

  Future<List<Product>> searchLaptops(String query) async {
    // This is a placeholder implementation.
    // Check the TechSpecs documentation for the correct endpoint and parameters.
    final response = await http.get(
      Uri.parse('$baseUrl/search?query=$query&category=laptops'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Adjust parsing based on actual response structure
      final List<dynamic> items = data['data'] ?? [];
      return items.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load laptops');
    }
  }

  Future<Product> getProductDetails(String productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/product/$productId'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Product.fromJson(data);
    } else {
      throw Exception('Failed to load product details');
    }
  }
}
