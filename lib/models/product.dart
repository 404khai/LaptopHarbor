class Product {
  final String id;
  final String brand;
  final String model;
  final String imageUrl;
  final List<String> imageUrls;
  final double price;
  final double? originalPrice;
  final String description;
  final Map<String, dynamic> specifications;
  final String category;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final int stock;

  Product({
    required this.id,
    required this.brand,
    required this.model,
    required this.imageUrl,
    List<String>? imageUrls,
    required this.price,
    this.originalPrice,
    required this.description,
    required this.specifications,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    this.stock = 0,
  }) : imageUrls = imageUrls ?? (imageUrl.isNotEmpty ? [imageUrl] : const []);

  factory Product.fromJson(Map<String, dynamic> json) {
    String pickString(Map<String, dynamic> map, List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
        if (value != null) {
          final asString = value.toString().trim();
          if (asString.isNotEmpty && asString != 'null') return asString;
        }
      }
      return '';
    }

    double pickDouble(Map<String, dynamic> map, List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value is num) return value.toDouble();
        if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
      return 0.0;
    }

    int pickInt(Map<String, dynamic> map, List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
      return 0;
    }

    bool pickBool(Map<String, dynamic> map, List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value is bool) return value;
        if (value is String) {
          final v = value.trim().toLowerCase();
          if (v == 'true') return true;
          if (v == 'false') return false;
        }
        if (value is num) return value != 0;
      }
      return false;
    }

    final productData = (json['product'] is Map)
        ? Map<String, dynamic>.from(json['product'] as Map)
        : json;
    final priceData = (json['price'] is Map)
        ? Map<String, dynamic>.from(json['price'] as Map)
        : productData;

    final id = pickString(productData, ['id', 'product_id', 'productId', '_id']);
    final brand = pickString(productData, ['brand', 'brandName', 'manufacturer']);
    final model = pickString(productData, ['model', 'name', 'title']);
    final imageUrl = pickString(productData, [
      'imageUrl',
      'image_url',
      'image',
      'thumbnail',
      'thumb',
      'photo',
      'picture',
    ]);

    final imageUrls = <String>[];
    final rawImageUrls = productData['imageUrls'] ?? productData['images'];
    if (rawImageUrls is List) {
      for (final item in rawImageUrls) {
        if (item is String && item.trim().isNotEmpty) {
          imageUrls.add(item.trim());
        } else if (item != null) {
          final asString = item.toString().trim();
          if (asString.isNotEmpty && asString != 'null') imageUrls.add(asString);
        }
      }
    }
    if (imageUrls.isEmpty && imageUrl.isNotEmpty) {
      imageUrls.add(imageUrl);
    }

    final description =
        pickString(productData, ['description', 'summary', 'about']);
    final category = pickString(productData, ['category', 'type']);

    final specs = <String, dynamic>{};
    final inside = productData['inside'];
    if (inside is Map) {
      specs.addAll(Map<String, dynamic>.from(inside));
    }
    final display = productData['display'];
    if (display is Map) {
      specs['display'] = Map<String, dynamic>.from(display);
    }

    return Product(
      id: id,
      brand: brand,
      model: model,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      price: pickDouble(priceData, ['price', 'msrp', 'amount']),
      originalPrice: (() {
        final value = productData['originalPrice'] ??
            productData['original_price'] ??
            productData['msrp'];
        if (value == null) return null;
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value);
        return null;
      })(),
      description: description,
      specifications: specs,
      category: category.isNotEmpty ? category : 'Laptop',
      rating: pickDouble(productData, ['rating', 'stars']),
      reviewCount: pickInt(productData, ['reviewCount', 'reviews', 'review_count']),
      inStock: pickBool(productData, ['inStock', 'in_stock', 'available']),
      stock: pickInt(productData, ['stock', 'inventory']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'price': price,
      'originalPrice': originalPrice,
      'description': description,
      'specifications': specifications,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'inStock': inStock,
      'stock': stock,
    };
  }
}
