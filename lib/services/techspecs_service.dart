import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/product.dart';

class TechSpecsService {
  final String baseUrl = 'https://api.techspecs.io/v5';
  final String _apiKey;
  final String _apiId;
  final http.Client _client;

  TechSpecsService({String? apiKey, String? apiId, http.Client? client})
    : _apiKey = apiKey ?? dotenv.env['TECHSPECS_API_KEY'] ?? '',
      _apiId = apiId ?? dotenv.env['TECHSPECS_API_ID'] ?? '',
      _client = client ?? http.Client();

  void _ensureCredentials() {
    if (_apiKey.isEmpty || _apiId.isEmpty) {
      throw StateError('Missing TECHSPECS_API_KEY or TECHSPECS_API_ID');
    }
  }

  Map<String, String> get _headers => {
    'x-api-key': _apiKey,
    'x-api-id': _apiId,
    'accept': 'application/json',
    'content-type': 'application/json',
  };

  String? _pickString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value != null) {
        final asString = value.toString().trim();
        if (asString.isNotEmpty && asString != 'null') return asString;
      }
    }
    return null;
  }

  double? _pickDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> _sendJson(http.BaseRequest request) async {
    _ensureCredentials();
    request.headers.addAll(_headers);
    final response = await http.Response.fromStream(
      await _client.send(request),
    );
    final body = response.body;
    final decoded = (body.isNotEmpty) ? jsonDecode(body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{'data': decoded};
    }

    String message = 'TechSpecs request failed';
    if (decoded is Map<String, dynamic>) {
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        message = _pickString(error, ['message']) ?? message;
      }
      message = _pickString(decoded, ['message']) ?? message;
    }

    throw Exception('$message (status: ${response.statusCode})');
  }

  Future<List<Product>> searchLaptops(String query) async {
    final items = await searchProducts(query: query, category: 'Laptops');
    return items.map((item) => _productFromSearchItem(item)).toList();
  }

  Future<List<Map<String, dynamic>>> searchProducts({
    required String query,
    String? category,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/products/search',
    ).replace(queryParameters: {'query': query});

    final request = http.Request('GET', uri);
    final normalizedCategory = category?.trim();
    if (normalizedCategory != null && normalizedCategory.isNotEmpty) {
      request.body = jsonEncode({'category': normalizedCategory});
    }

    final decoded = await _sendJson(request);
    final data = decoded['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }

  Product _productFromSearchItem(Map<String, dynamic> item) {
    final id =
        _pickString(item, ['id', 'product_id', 'productId', '_id']) ?? '';
    final brand =
        _pickString(item, ['brand', 'brandName', 'manufacturer']) ?? '';
    final model =
        _pickString(item, ['model', 'name', 'title', 'product']) ?? '';
    final imageUrl =
        _pickString(item, [
          'imageUrl',
          'image',
          'thumbnail',
          'thumb',
          'photo',
          'picture',
        ]) ??
        '';
    final price = _pickDouble(item, ['price', 'msrp', 'amount']) ?? 0.0;

    return Product(
      id: id,
      brand: brand,
      model: model,
      imageUrl: imageUrl,
      price: price,
      originalPrice: null,
      description: '',
      specifications: const {},
      category: 'Laptop',
    );
  }

  Future<Product> getProductDetails(String productId) async {
    final uri = Uri.parse('$baseUrl/products/$productId');
    final decoded = await _sendJson(http.Request('GET', uri));
    final data = decoded['data'];
    if (data is Map) {
      return Product.fromJson(Map<String, dynamic>.from(data));
    }
    return Product.fromJson(decoded);
  }

  Future<List<String>> getProductImages(
    String productId, {
    bool includeGallery = true,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/products/$productId/images',
    ).replace(queryParameters: {'includeGallery': includeGallery.toString()});
    final decoded = await _sendJson(http.Request('GET', uri));
    final data = decoded['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map(
            (e) =>
                _pickString(e, ['url', 'imageUrl', 'image', 'src', 'link']) ??
                '',
          )
          .where((u) => u.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }

  Future<List<Map<String, String>>> getBrandLogos() async {
    final uri = Uri.parse('$baseUrl/brand-logos');
    final decoded = await _sendJson(http.Request('GET', uri));
    final data = decoded['data'];
    if (data is List) {
      final items = <Map<String, String>>[];
      for (final raw in data) {
        if (raw is! Map) continue;
        final map = Map<String, dynamic>.from(raw);
        final logo = _pickString(map, ['logo', 'logoUrl', 'url', 'imageUrl']);
        final brand = _pickString(map, ['brand', 'name', 'brandName']);
        if (logo != null && logo.isNotEmpty) {
          items.add({'logoUrl': logo, if (brand != null) 'brand': brand});
        }
      }
      return items;
    }
    return const <Map<String, String>>[];
  }

  Future<List<String>> getCategories({int page = 0, int size = 10}) async {
    final uri = Uri.parse(
      '$baseUrl/categories',
    ).replace(queryParameters: {'page': '$page', 'size': '$size'});
    final decoded = await _sendJson(http.Request('GET', uri));
    final data = decoded['data'];
    if (data is List) {
      return data
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (data is Map && data['content'] is List) {
      return (data['content'] as List)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }
}
