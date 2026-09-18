import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  static String _activeBaseUrl = 'http://127.0.0.1:8000/api';
  static final List<String> _possibleUrls = [
    'http://127.0.0.1:8000/api',
    'http://10.204.47.10:8000/api',
    'http://10.0.2.2:8000/api',
  ];

  static String get baseUrl => _activeBaseUrl;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000/api',
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
    ),
  );
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.baseUrl = _activeBaseUrl;
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.error is SocketException) {
            for (final nextUrl in _possibleUrls) {
              if (nextUrl != _activeBaseUrl) {
                _activeBaseUrl = nextUrl;
                _dio.options.baseUrl = nextUrl;
                try {
                  final opts = e.requestOptions;
                  final fullPath = opts.path.startsWith('http')
                      ? opts.path
                      : '$nextUrl${opts.path.startsWith('/') ? '' : '/'}${opts.path}';

                  final response = await Dio().request(
                    fullPath,
                    data: opts.data,
                    queryParameters: opts.queryParameters,
                    options: Options(
                      method: opts.method,
                      headers: opts.headers,
                      sendTimeout: const Duration(seconds: 3),
                      receiveTimeout: const Duration(seconds: 3),
                    ),
                  );
                  return handler.resolve(response);
                } catch (_) {}
              }
            }
          }

          if (e.response?.statusCode == 401) {
            final refreshToken = await _storage.read(key: 'refresh_token');
            if (refreshToken != null) {
              try {
                final response = await Dio().post(
                  '$_activeBaseUrl/auth/token/refresh/',
                  data: {'refresh': refreshToken},
                );
                final newAccess = response.data['access'];
                await _storage.write(key: 'access_token', value: newAccess);

                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccess';
                final cloneReq = await _dio.request(
                  opts.path,
                  options: Options(method: opts.method, headers: opts.headers),
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                );
                return handler.resolve(cloneReq);
              } catch (_) {
                await _storage.deleteAll();
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await _dio.post('/auth/login/', data: {
      'username': username,
      'password': password,
    });
    await _storage.write(key: 'access_token', value: res.data['access']);
    await _storage.write(key: 'refresh_token', value: res.data['refresh']);
    return res.data;
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    String email = '',
    String gender = 'female',
    String preferredStyle = '',
  }) async {
    final res = await _dio.post('/auth/register/', data: {
      'username': username,
      'password': password,
      'email': email,
      'gender': gender,
      'preferred_style': preferredStyle,
    });
    await _storage.write(key: 'access_token', value: res.data['access']);
    await _storage.write(key: 'refresh_token', value: res.data['refresh']);
    return res.data;
  }

  Future<List<dynamic>> getWardrobe({String? category}) async {
    final params = (category != null && category != 'All') ? {'category': category} : null;
    final res = await _dio.get('/wardrobe/items/', queryParameters: params);
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> addWardrobeItem({
    required String name,
    required String category,
    required String color,
    String season = 'All',
    String occasion = 'Casual',
    String? imagePath,
  }) async {
    final Map<String, dynamic> mapData = {
      'name': name,
      'category': category,
      'color': color,
      'season': season,
      'occasion': occasion,
    };
    dynamic postData = mapData;
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (file.existsSync()) {
        postData = FormData.fromMap({
          ...mapData,
          'image': await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last),
        });
      }
    }
    final res = await _dio.post('/wardrobe/items/', data: postData);
    return res.data;
  }

  Future<void> deleteWardrobeItem(dynamic id) async {
    await _dio.delete('/wardrobe/items/$id/');
  }

  Future<Map<String, dynamic>> suggestOutfitOptions({required String occasion}) async {
    final res = await _dio.post('/wardrobe/suggest-options/', data: {
      'occasion': occasion,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> generateAvatarOutfit({
    required String occasion,
    required List<dynamic> itemIds,
  }) async {
    final res = await _dio.post('/wardrobe/generate-avatar/', data: {
      'occasion': occasion,
      'item_ids': itemIds,
    });
    return res.data;
  }

  Future<List<dynamic>> getOutfitHistory() async {
    final res = await _dio.get('/wardrobe/history/');
    return res.data as List<dynamic>;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
