import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';

final wardrobeServiceProvider = Provider<WardrobeService>((ref) {
  return WardrobeService(ref.read(apiServiceProvider));
});

class WardrobeItemModel {
  final int id;
  final String name;
  final String category;
  final String color;
  final String season;
  final String occasion;
  final String? image;
  final String? imageUrl;
  final int timesWorn;
  final DateTime createdAt;

  WardrobeItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.season,
    required this.occasion,
    this.image,
    this.imageUrl,
    required this.timesWorn,
    required this.createdAt,
  });

  factory WardrobeItemModel.fromJson(Map<String, dynamic> json) {
    return WardrobeItemModel(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? 'Tops',
      color: json['color'] ?? 'Black',
      season: json['season'] ?? 'All',
      occasion: json['occasion'] ?? 'Casual',
      image: json['image'],
      imageUrl: json['image_url'],
      timesWorn: json['times_worn'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class WardrobeService {
  final ApiService _apiService;

  WardrobeService(this._apiService);

  ApiService get apiService => _apiService;

  Future<List<WardrobeItemModel>> getWardrobeItems({String? category}) async {
    try {
      final items = await _apiService.getWardrobe(category: category);
      return items.map((e) => WardrobeItemModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
