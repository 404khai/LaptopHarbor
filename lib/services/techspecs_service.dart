import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/product.dart';

class TechSpecsService {
  final String baseUrl = 'https://api.techspecs.io/v5';
  final String _apiKey;

  TechSpecsService({String? apiKey})
    : _apiKey = apiKey ?? dotenv.env['TECHSPECS_API_KEY'] ?? '';

  Future<List<Product>> searchLaptops(String query) async {
    if (_apiKey.isEmpty) {
      throw StateError('Missing TECHSPECS_API_KEY');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/products/search?query=$query'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'category': 'laptops'}),
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
    if (_apiKey.isEmpty) {
      throw StateError('Missing TECHSPECS_API_KEY');
    }

    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    final endpoints = [
      Uri.parse('$baseUrl/products/$productId'),
      Uri.parse('$baseUrl/product/$productId'),
    ];

    http.Response? lastResponse;
    for (final endpoint in endpoints) {
      final response = await http.get(endpoint, headers: headers);
      lastResponse = response;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data);
      }
    }

    throw Exception(
      'Failed to load product details (status: ${lastResponse?.statusCode ?? 'unknown'})',
    );
  }
}
