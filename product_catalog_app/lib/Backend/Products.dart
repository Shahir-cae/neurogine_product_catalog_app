import 'dart:convert';
import 'package:http/http.dart' as http;

class Product {
  final int id;
  final String title;
  final String description;
  final num price;
  final num rating;
  final String category;
  final String thumbnail;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.category,
    required this.thumbnail,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: json['price'] as num,
      rating: json['rating'] as num,
      category: json['category'] as String,
      thumbnail: json['thumbnail'] as String,
    );
  }
}

class ProductService {
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products?limit=20&skip=0'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final productsJson = body['products'] as List<dynamic>;

      return productsJson
          .map((productJson) => Product.fromJson(productJson as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch products: ${response.statusCode}');
    }
  }
}
