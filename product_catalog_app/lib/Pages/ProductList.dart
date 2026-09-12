import 'dart:async';
import 'package:flutter/material.dart';
import 'Widget/TopBar.dart';
import 'Widget/ProductCard.dart';
import '../Backend/Products.dart';
import 'ProductDetail.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Product> _products = [];        // paginated master list
  List<Product> _searchResults = [];   // NEW: only holds search results
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  int _skip = 0;
  static const int _limit = 20;

  final ScrollController _scrollController = ScrollController();

  bool _isSearchMode = false;
  Timer? _debounce;

  // NEW: single source of truth for "what should the list show right now"
  List<Product> get _displayedProducts =>
      _isSearchMode ? _searchResults : _products;

  @override
  void initState() {
    super.initState();
    _loadInitialProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isSearchMode) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      // NEW: this is the actual "reset to default list" logic —
      // just flip the mode flag back. _products was never touched,
      // so it's still sitting there fully intact.
      setState(() {
        _isSearchMode = false;
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearchMode = true;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await ProductService.searchProductByName(query);
      setState(() {
        _searchResults = results; // only this list changes, not _products
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadInitialProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _skip = 0;
      _hasMore = true;
    });

    try {
      final products = await ProductService.fetchProducts(
        limit: _limit,
        skip: 0,
      );
      setState(() {
        _products = products;
        _isLoading = false;
        _skip = products.length;
        _hasMore = products.length == _limit;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final moreProducts = await ProductService.fetchProducts(
        limit: _limit,
        skip: _skip,
      );
      setState(() {
        _products.addAll(moreProducts);
        _skip += moreProducts.length;
        _hasMore = moreProducts.length == _limit;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _retry() {
    if (_isSearchMode) {
      setState(() {
        _isSearchMode = false;
        _searchResults = [];
      });
    }
    _loadInitialProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopBar(onSearchChanged: _onSearchChanged),
          Expanded(child: _buildBody()),
        ],
      ),
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
              onPressed: _retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // CHANGED: check _displayedProducts, not _products directly
    if (_displayedProducts.isEmpty) {
      return Center(
        child: Text(
          _isSearchMode ? 'No matching products found.' : 'No products found.',
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount:
          _displayedProducts.length + (_isLoadingMore && !_isSearchMode ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _displayedProducts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // CHANGED: read from _displayedProducts, not _products
        final product = _displayedProducts[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetail(productId: product.id),
              ),
            );
          },
          child: ProductCard(
            thumbnail: product.thumbnail,
            productName: product.title,
            productDescription: product.description,
            productPrice: product.price.toDouble(),
            productRating: product.rating.toDouble(),
          ),
        );
      },
    );
  }
}