import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_sme_app/app/data/api_config.dart';

class PriceService {
  // === KONFIGURASI URL BACKEND ===
  // Mengambil hostname dari ApiConfig.BASE_URL dan mengganti /api/v1 dengan /api/harga
  final String baseUrl = ApiConfig.BASE_URL.replaceAll('/api/v1', '/api/harga/');

  /// 1. FUNGSI UNTUK MENGAMBIL DATA TREN HARGA (UNTUK GRAFIK)
  /// Mengembalikan List berisi Map data historis dari MongoDB
  Future<List<Map<String, dynamic>>> getPriceTrend({int limit = 7}) async {
    try {
      // Menembak endpoint: ${baseUrl}trend?limit=$limit
      final url = '${baseUrl}trend?limit=$limit';
      print('🔍 [PriceService] Fetching trend dari: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          ...ApiConfig.getHeaders(),
          "ngrok-skip-browser-warning": "true",
        },
      );

      if (response.statusCode == 200) {
        // Dekode response body dari string JSON menjadi List dynamic
        final List<dynamic> decodedData = jsonDecode(response.body);

        // Mengubah List<dynamic> menjadi List<Map<String, dynamic>> agar aman digunakan di Flutter
        return decodedData.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception(
            "Gagal memuat data tren. Kode Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal terhubung ke server (Trend): $e");
    }
  }

  /// 2. FUNGSI UNTUK MENGAMBIL DATA REKOMENDASI HARGA TERBARU
  /// Mengembalikan List Map data rekomendasi
  Future<List<Map<String, dynamic>>> getPriceRecommendation() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.BASE_URL}/market/analysis'),
        headers: {
          ...ApiConfig.getHeaders(),
          "ngrok-skip-browser-warning": "true",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // Memastikan respon memiliki key 'data' (format baru dari endpoint analysis)
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> decodedData = responseData['data'];
          return decodedData.map((item) => item as Map<String, dynamic>).toList();
        } else {
          // Fallback jika API mengembalikan langsung sebuah list
          final List<dynamic> decodedData = jsonDecode(response.body);
          return decodedData.map((item) => item as Map<String, dynamic>).toList();
        }
      } else {
        throw Exception(
            "Gagal memuat data rekomendasi. Kode Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal terhubung ke server (Rekomendasi): $e");
    }
  }
}