class ApiConfig {
  static const String BASE_URL = 'https://backend-sme.up.railway.app/api/v1';

  static void logNetwork(String url) {
    print('====================================');
    print('CCTV FRONTEND: Mengirim request ke:');
    print('URL Target: $url');
    print('====================================');
  }
}
