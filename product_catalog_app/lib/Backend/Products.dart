import 'dart:convert';
import 'package:http/http.dart' as http;

class Review {
  final int rating;
  final String comment;
  final String reviewerName;

  Review({
    required this.rating,
    required this.comment,
    required this.reviewerName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      reviewerName: json['reviewerName'] as String,
    );
  }
}

class Product {
  final int id;
  final String title;
  final String description;
  final num price;
  final num rating;
  final String category;
  final String thumbnail;
  final List<String> images;
  final num discountPercentage;
  final List<Review> reviews;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.category,
    required this.thumbnail,
    required this.images,
    required this.discountPercentage,
    required this.reviews,
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
      images: (json['images'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      discountPercentage: json['discountPercentage'] as num,
      reviews: (json['reviews'] as List<dynamic>)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProductService {
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products'),
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

  static Future<Product> fetchProductById(int id) async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products/$id'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Product.fromJson(body as Map<String, dynamic>);
    } else {
      throw Exception('Failed to fetch product: ${response.statusCode}');
    }
  }
}