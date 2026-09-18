import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_service.dart';
import '../home/home_screen.dart';
import '../auth/welcome_screen.dart';

class WardrobeItemManual {
  final String id;
  final String imagePath;
  String name;
  String category;
  String color;
  String season;
  String occasion;

  WardrobeItemManual({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.category,
    required this.color,
    required this.season,
    required this.occasion,
  });
}

class AddWardrobeScreen extends ConsumerStatefulWidget {
  const AddWardrobeScreen({super.key});

  @override
  ConsumerState<AddWardrobeScreen> createState() => _AddWardrobeScreenState();
}

class _AddWardrobeScreenState extends ConsumerState<AddWardrobeScreen> {
  final bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();
  final List<WardrobeItemManual> _wardrobeItems = [];
  String _selectedCategoryFilter = 'All';

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

  final List<String> _seasons = ['All', 'Summer', 'Winter', 'Fall', 'Spring'];
  final List<String> _occasions = ['Casual', 'Formal', 'Party', 'Workout', 'Work'];

  final List<Map<String, dynamic>> _popularColors = [
    {'name': 'Black', 'color': Colors.black},
    {'name': 'White', 'color': Colors.white},
    {'name': 'Red', 'color': const Color(0xFFEF4444)},
    {'name': 'Blue', 'color': const Color(0xFF3B82F6)},
    {'name': 'Pink', 'color': const Color(0xFFEC4899)},
    {'name': 'Green', 'color': const Color(0xFF10B981)},
    {'name': 'Yellow', 'color': const Color(0xFFF59E0B)},
    {'name': 'Purple', 'color': const Color(0xFF9333EA)},
    {'name': 'Beige', 'color': const Color(0xFFD97706)},
    {'name': 'Navy', 'color': const Color(0xFF1E3A8A)},
    {'name': 'Orange', 'color': const Color(0xFFEA580C)},
  ];

  @override
  void initState() {
    super.initState();
    _retrieveLostData();
  }

  Future<void> _retrieveLostData() async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) return;
      if (response.file != null) {
        _showAddItemDialog(response.file!.path);
      }
    } catch (_) {}
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage(
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );
        if (images.isNotEmpty) {
          for (var img in images) {
            await _showAddItemDialog(img.path);
          }
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
          preferredCameraDevice: CameraDevice.rear,
        );
        if (image != null) {
          _showAddItemDialog(image.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access camera/gallery: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Future<void> _showAddItemDialog(String imagePath, {WardrobeItemManual? existingItem}) async {
    final nameController = TextEditingController(text: existingItem?.name ?? '');
    final colorController = TextEditingController(text: existingItem?.color ?? 'Purple');
    String category = existingItem?.category ?? 'Tops';
    String season = existingItem?.season ?? 'All';
    String occasion = existingItem?.occasion ?? 'Casual';
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            existingItem == null ? 'Add Dress / Cloth Details 👗' : 'Edit Dress Details',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B0764),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFF6B21A8)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Image Thumbnail Preview
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(imagePath),
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 110,
                              height: 110,
                              color: const Color(0xFFFAF5FF),
                              child: const Icon(Icons.checkroom_rounded, color: Color(0xFF6B21A8), size: 40),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 1. Dress / Item Name Input
                      _buildLabel('Dress / Item Name'),
                      TextFormField(
                        controller: nameController,
                        decoration: _buildInputDecoration(
                          hint: 'e.g., Purple Silk Blouse, Blue Jeans',
                          icon: Icons.label_outlined,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter an item name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // 2. Cloth Type / Category
                      _buildLabel('Cloth Type / Category'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.where((c) => c != 'All').map((cat) {
                          final isSel = category == cat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSel,
                            selectedColor: const Color(0xFF6B21A8),
                            backgroundColor: const Color(0xFFFAF5FF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : const Color(0xFF6B21A8),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            onSelected: (selected) {
                              if (selected) setModalState(() => category = cat);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // 3. Color Selection / Input
                      _buildLabel('Color'),
                      TextFormField(
                        controller: colorController,
                        decoration: _buildInputDecoration(
                          hint: 'Enter or select color (e.g. Lavender, Black)',
                          icon: Icons.palette_outlined,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter or select a color';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      // Quick Palette Color Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _popularColors.map((col) {
                          final isSel = colorController.text.toLowerCase() == (col['name'] as String).toLowerCase();
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                colorController.text = col['name'] as String;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFF6B21A8) : const Color(0xFFFAF5FF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSel ? const Color(0xFF6B21A8) : const Color(0xFFE9D5FF),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: col['color'] as Color,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey.shade400, width: 0.5),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    col['name'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSel ? Colors.white : const Color(0xFF3B0764),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // 4. Season & Occasion
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Season'),
                                DropdownButtonFormField<String>(
                                  initialValue: season,
                                  decoration: _buildInputDecoration(hint: 'Season', icon: Icons.wb_sunny_outlined),
                                  items: _seasons.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => season = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Occasion'),
                                DropdownButtonFormField<String>(
                                  initialValue: occasion,
                                  decoration: _buildInputDecoration(hint: 'Occasion', icon: Icons.event_outlined),
                                  items: _occasions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => occasion = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6B21A8), Color(0xFF9333EA)],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            final name = nameController.text.trim();
                            final color = colorController.text.trim();
                            final api = ref.read(apiServiceProvider);

                            try {
                              await api.addWardrobeItem(
                                name: name,
                                category: category,
                                color: color,
                                season: season,
                                occasion: occasion,
                                imagePath: imagePath,
                              );
                            } on DioException catch (e) {
                              if (e.response?.statusCode == 401 && context.mounted) {
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
                                return;
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to save: ${e.message}'),
                                    backgroundColor: const Color(0xFFDC2626),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to save to server: $e'),
                                    backgroundColor: const Color(0xFFDC2626),
                                  ),
                                );
                              }
                            }

                            setState(() {
                              if (existingItem != null) {
                                existingItem.name = name;
                                existingItem.category = category;
                                existingItem.color = color;
                                existingItem.season = season;
                                existingItem.occasion = occasion;
                              } else {
                                _wardrobeItems.add(
                                  WardrobeItemManual(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    imagePath: imagePath,
                                    name: name,
                                    category: category,
                                    color: color,
                                    season: season,
                                    occasion: occasion,
                                  ),
                                );
                              }
                            });

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added "$name" to your wardrobe!'),
                                  backgroundColor: const Color(0xFF6B21A8),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            'Save Item',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _removeItem(String id) {
    setState(() {
      _wardrobeItems.removeWhere((item) => item.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _selectedCategoryFilter == 'All'
        ? _wardrobeItems
        : _wardrobeItems.where((i) => i.category == _selectedCategoryFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Purple Banner Header
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3B0764),
                        Color(0xFF6B21A8),
                        Color(0xFF9333EA),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Add Wardrobe Items',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                                    (route) => false,
                                  );
                                },
                                child: const Text(
                                  'Skip for now',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Add Your Wardrobe 👗',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                          const SizedBox(height: 4),
                          Text(
                            'Upload dress photos from your gallery & manually tag color and cloth type',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action Options (From Gallery / Take Photo)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B21A8).withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Select Dress Photos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B0764),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pick from your phone gallery, then enter color & cloth type manually',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF6B21A8).withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          // Gallery Button
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickImage(ImageSource.gallery),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF5FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE9D5FF),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.photo_library_rounded,
                                      color: Color(0xFF6B21A8),
                                      size: 32,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Add from Gallery',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3B0764),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Camera Button
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickImage(ImageSource.camera),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF5FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE9D5FF),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.camera_alt_rounded,
                                      color: Color(0xFF9333EA),
                                      size: 32,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Take Photo',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3B0764),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
              ),
            ),
          ),

          // Category Filter Horizontal Scroll
          if (_wardrobeItems.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Added Items',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B0764),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B21A8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_wardrobeItems.length} Items',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _categories.map((cat) {
                          final isSel = _selectedCategoryFilter == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSel,
                              selectedColor: const Color(0xFF6B21A8),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isSel ? const Color(0xFF6B21A8) : const Color(0xFFE9D5FF),
                              ),
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : const Color(0xFF6B21A8),
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategoryFilter = cat;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

          // Grid View of Added Items
          if (filteredItems.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filteredItems[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B21A8).withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFF3E8FF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail + Category Tag + Delete Button
                          Expanded(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: Image.file(
                                    File(item.imagePath),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: const Color(0xFFF3E8FF),
                                      child: const Center(
                                        child: Icon(
                                          Icons.checkroom_rounded,
                                          color: Color(0xFF6B21A8),
                                          size: 36,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Category Tag Badge
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6B21A8),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      item.category,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                // Delete Button
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () => _removeItem(item.id),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Details
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
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
                                      '🎨 ${item.color}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF6B21A8).withValues(alpha: 0.85),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _showAddItemDialog(item.imagePath, existingItem: item),
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF9333EA),
                                        ),
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
                  },
                  childCount: filteredItems.length,
                ),
              ),
            ),

          // Save & Proceed Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B21A8), Color(0xFF9333EA)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9333EA).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Wardrobe items saved successfully! Welcome to OOTDee.'),
                                backgroundColor: Color(0xFF6B21A8),
                              ),
                            );
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                                (route) => false,
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Save & Continue to Wardrobe',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 200.ms),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3B0764),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFF6B21A8).withValues(alpha: 0.4),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF6B21A8), size: 18),
      filled: true,
      fillColor: const Color(0xFFFAF5FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE9D5FF), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF9333EA), width: 2),
      ),
    );
  }
}
