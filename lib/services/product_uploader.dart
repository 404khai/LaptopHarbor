import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductUploader {
  static Future<void> uploadProductsToFirestore() async {
    try {
      debugPrint('Starting product upload...');

      final String jsonString = await rootBundle.loadString('assets/data/products.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final productsRaw = jsonData['products'];
      if (productsRaw is! List) {
        throw StateError('Invalid products.json format: "products" must be a List');
      }
      final List<dynamic> products = productsRaw;

      debugPrint('Loaded ${products.length} products from JSON.');

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final CollectionReference productsCollection = firestore.collection('products');

      final int batchSize = 400;
      int totalUploaded = 0;

      for (var i = 0; i < products.length; i += batchSize) {
        final WriteBatch batch = firestore.batch();
        final end = (i + batchSize < products.length) ? i + batchSize : products.length;
        final chunk = products.sublist(i, end);

        for (final product in chunk) {
          if (product is! Map) continue;
          final String docId = (product['id'] ?? '').toString();
          if (docId.isEmpty) continue;
          final DocumentReference docRef = productsCollection.doc(docId);
          batch.set(docRef, Map<String, dynamic>.from(product));
        }

        await batch.commit();
        totalUploaded += chunk.length;
        debugPrint(
          'Progress: $totalUploaded / ${products.length} products uploaded.',
        );
      }

      debugPrint('Upload complete! Successfully uploaded $totalUploaded products.');
    } catch (e) {
      debugPrint('Error uploading products: $e');
      rethrow;
    }
  }
}
