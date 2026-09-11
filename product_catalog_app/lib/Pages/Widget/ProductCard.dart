import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String thumbnail;
  final String productName;
  final String productDescription;
  final double productPrice;
  final double productRating;

  const ProductCard({
    super.key,
    required this.thumbnail,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.productRating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100.0,
              height: 100.0,
              child: Image.network(
                thumbnail,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    productDescription.length > 50
                        ? '${productDescription.substring(0, 50)}...'
                        : productDescription,
                    style: const TextStyle(fontSize: 10.0),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 25.0),
                      const SizedBox(width: 4.0),
                      Text(
                        productRating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'RM ${productPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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
}