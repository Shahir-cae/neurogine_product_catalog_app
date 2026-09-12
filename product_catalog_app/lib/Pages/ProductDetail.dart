import 'package:flutter/material.dart';
import '../Backend/Products.dart';

class ProductDetail extends StatefulWidget {
  final int productId;

  const ProductDetail({super.key, required this.productId});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;

  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final product = await ProductService.fetchProductById(widget.productId);
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Something went wrong: $_errorMessage'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadProduct,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final product = _product!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // only show one image at a time
          SizedBox(
            height: 220.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: product.images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Center(
                      child: Image.network(
                        product.images[index],
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),

                // Left arrow — hidden if only 1 image, or already on first image
                if (product.images.length > 1 && _currentImageIndex > 0)
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),

                // Right arrow — hidden if only 1 image, or already on last image
                if (product.images.length > 1 &&
                    _currentImageIndex < product.images.length - 1)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.black54),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Dot indicators showing position in the gallery
          if (product.images.length > 1) ...[
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                product.images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentImageIndex
                        ? Colors.blue
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16.0),
          Text(
            product.title,
            style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20.0),
              const SizedBox(width: 4.0),
              Text(product.rating.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            'RM ${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            product.description,
            style: const TextStyle(fontSize: 20.0),
          ),
          if (product.discountPercentage > 0) ...[
            const SizedBox(height: 8.0),
            Text(
              '${product.discountPercentage.toStringAsFixed(0)}% OFF',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
          const SizedBox(height: 24.0),
          Text(
            'Reviews (${product.reviews.length})',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          ...product.reviews.map((review) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.reviewerName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8.0),
                        Row(
                          children: List.generate(
                            review.rating,
                            (i) => const Icon(Icons.star, color: Colors.amber, size: 14.0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(review.comment),
                  ],
                ),
              )
            ),
        ],
      ),
    );
  }
}