import 'package:get/get.dart';
import 'package:smart_sme_app/app/data/api_config.dart';

class MarketProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = ApiConfig.BASE_URL; // Menggunakan Ngrok / FastAPI
    
    // HTTP INTERCEPTOR: Set Timeout 10 detik agar tidak stuck
    httpClient.timeout = const Duration(seconds: 10);
    
    // Header bypass Ngrok (jika diperlukan)
    httpClient.addRequestModifier((request) {
      request.headers['ngrok-skip-browser-warning'] = 'true';
      print('URL REQUEST MARKET: ${request.url}');
      return request;
    });
    
    super.onInit();
  }

  // Menambahkan parameter sort untuk API backend
  Future<Response> getMarketProducts(String sortQuery) {
    String endpoint = '/market/products';
    if (sortQuery.isNotEmpty) {
      endpoint += '?sort=$sortQuery';
    }
    return get(endpoint);
  }

  // Mengambil data analisis market terbaru (T-Shirt Price Monitoring)
  Future<Response> getMarketAnalysis() {
    return get('/market/analysis');
  }

  // Fungsi POST untuk Analytic Logging
  Future<Response> logProductView(String userId, String productId) {
    return post('/market/log-view', {
      'user_id': userId,
      'product_id': productId,
    });
  }
}
