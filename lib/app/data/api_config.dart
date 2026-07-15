import 'package:get_storage/get_storage.dart';

class ApiConfig {
  static const String BASE_URL = 'https://backend-sme.up.railway.app/api/v1';

  static void logNetwork(String url) {
    print('====================================');
    print('CCTV FRONTEND: Mengirim request ke:');
    print('URL Target: $url');
    print('====================================');
  }

  static Map<String, String> getHeaders() {
    final box = GetStorage();
    final String? token = box.read('access_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
