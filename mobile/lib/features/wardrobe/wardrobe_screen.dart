import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_service.dart';
import 'add_wardrobe_screen.dart';
import '../auth/welcome_screen.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  String _selectedCategory = 'All';
  bool _isLoading = true;
  List<dynamic> _wardrobeItems = [];

  final List<String> _categories = [
    'All',
    'Tops',
    'Bottoms',
    'Dresses',
    'Jumpsuit',
    'Jeggings',
    'Kurta',
    'Jacket',
    'Shorts',
    'Outerwear',
    'Lehanga',
    'Saree',
    'Shoes',
    'Accessories',
  ];

  @override
  void initState() {
    super.initState();
    _fetchWardrobe();
  }

  Future<void> _fetchWardrobe() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final items = await api.getWardrobe();
      if (mounted) {
        setState(() {
          _wardrobeItems = items;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _wardrobeItems = [];
          _isLoading = false;
        });
        if (e.response?.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please log in again.'),
              backgroundColor: Color(0xFFDC2626),
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load wardrobe: ${e.message}'),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _wardrobeItems = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load wardrobe: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter items based on selected category tab
    final filteredItems = _selectedCategory == 'All'
        ? _wardrobeItems
        : _wardrobeItems.where((item) => item['category'].toString().toLowerCase() == _selectedCategory.toLowerCase()).toList();

    // Group items by Category for structured category sections layout
    final Map<String, List<dynamic>> groupedItems = {};
    for (var item in _wardrobeItems) {
      final rawCat = item['category']?.toString() ?? 'Others';
      if (rawCat.isEmpty) continue;
      final catKey = rawCat[0].toUpperCase() + rawCat.substring(1);
      groupedItems.putIfAbsent(catKey, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Closet 👗',
          style: TextStyle(
            color: Color(0xFF3B0764),
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_rounded, color: Color(0xFF6B21A8)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddWardrobeScreen()),
              ).then((_) => _fetchWardrobe());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips Horizontal Scroll Bar
          Container(
            height: 56,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: const Color(0xFF6B21A8),
                  backgroundColor: const Color(0xFFFAF5FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6B21A8),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              },
            ),
          ),

          // Total Items & Add Button Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredItems.length} Garments in My Closet',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B0764),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B21A8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AddWardrobeScreen()),
                    ).then((_) => _fetchWardrobe());
                  },
                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 16),
                  label: const Text('Add from Gallery', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Content Area: Categorized Sections or Filtered Grid View
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B21A8)))
                : _wardrobeItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.checkroom_outlined, size: 64, color: Color(0xFFC084FC)),
                            const SizedBox(height: 16),
                            const Text(
                              'Your Closet is Empty',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B0764),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap below to add your clothes & build your wardrobe!',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const AddWardrobeScreen()),
                                ).then((_) => _fetchWardrobe());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B21A8),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
                              label: const Text('Add Clothes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      )
                : _selectedCategory == 'All'
                    ? ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: groupedItems.entries.map((entry) {
                          final categoryName = entry.key;
                          final catItems = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Section Title
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9333EA),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      categoryName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3B0764),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3E8FF),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${catItems.length}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF6B21A8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Horizontal List of Garments in Category
                              SizedBox(
                                height: 170,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: catItems.length,
                                  itemBuilder: (context, idx) {
                                    final item = catItems[idx];
                                    return _buildGarmentCard(item);
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _buildGridGarmentCard(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildGarmentImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: const Color(0xFFFAF5FF),
        child: const Center(
          child: Icon(Icons.checkroom_rounded, color: Color(0xFF6B21A8), size: 36),
        ),
      );
    }

    if (!imageUrl.startsWith('http')) {
      final localFile = File(imageUrl);
      if (localFile.existsSync()) {
        return Image.file(localFile, width: double.infinity, fit: BoxFit.cover);
      }
    }

    String netUrl = imageUrl;
    if (!netUrl.startsWith('http')) {
      final serverBase = ApiService.baseUrl.replaceAll('/api', '');
      netUrl = '$serverBase${netUrl.startsWith('/') ? '' : '/'}$netUrl';
    }

    return Image.network(
      netUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFFFAF5FF),
        child: const Center(
          child: Icon(Icons.checkroom_rounded, color: Color(0xFF6B21A8), size: 36),
        ),
      ),
    );
  }

  Widget _buildGarmentCard(Map<String, dynamic> item) {
    final name = item['name'] ?? 'Garment';
    final color = item['color'] ?? '';
    final imageUrl = (item['image_url'] ?? item['image']) as String?;

    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B21A8).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3E8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: _buildGarmentImage(imageUrl),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF3B0764),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '🎨 $color',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B21A8).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridGarmentCard(Map<String, dynamic> item) {
    final name = item['name'] ?? 'Garment';
    final color = item['color'] ?? '';
    final category = item['category'] ?? '';
    final imageUrl = (item['image_url'] ?? item['image']) as String?;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B21A8).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3E8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: _buildGarmentImage(imageUrl),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF3B0764),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🎨 $color',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B21A8).withValues(alpha: 0.8),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF6B21A8), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
