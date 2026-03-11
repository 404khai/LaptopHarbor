class Product {
  final String id;
  final String brand;
  final String model;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final String description;
  final Map<String, dynamic> specifications;
  final String category;

  Product({
    required this.id,
    required this.brand,
    required this.model,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    required this.description,
    required this.specifications,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // This mapping depends heavily on the actual API response structure.
    // Based on the snippet, it seems complex. 
    // For now, we'll assume a simplified structure or map it manually.
    
    // Example mapping (adjust based on actual API):
    final productData = json['product'] ?? {};
    final priceData = json['price'] ?? {};
    
    return Product(
      id: productData['id'] ?? '',
      brand: productData['brand'] ?? '',
      model: productData['model'] ?? '',
      imageUrl: productData['image'] ?? '', // Placeholder, need actual field
      price: double.tryParse(priceData['price']?.toString() ?? '0') ?? 0.0,
      description: productData['description'] ?? '',
      specifications: {
        'processor': productData['inside']?['processor'] ?? {},
        'ram': productData['inside']?['ram'] ?? {},
        'storage': productData['inside']?['storage'] ?? {},
        'display': productData['display'] ?? {},
      },
      category: productData['category'] ?? 'Laptop',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'imageUrl': imageUrl,
      'price': price,
      'originalPrice': originalPrice,
      'description': description,
      'specifications': specifications,
      'category': category,
    };
  }
}
