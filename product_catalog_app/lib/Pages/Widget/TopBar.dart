import 'package:flutter/material.dart';

class TopBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;

  const TopBar({super.key, required this.onSearchChanged});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        // Closing the search box — clear the text and tell the
        // parent to reset back to the normal product list.
        _searchController.clear();
        widget.onSearchChanged('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _isSearching
                    ? TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: widget.onSearchChanged,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                      )
                    : const Text(
                        'Product Catalog',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(_isSearching ? Icons.close : Icons.search),
                    color: Colors.white,
                    onPressed: _toggleSearch,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}