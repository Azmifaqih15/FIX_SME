import 'package:get/get.dart';

class FashionProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'https://braden-noncrusading-uncarnivorously.ngrok-free.dev/api/v1/';
    httpClient.timeout = const Duration(seconds: 10);
    
    // Tambahkan Header Default ini untuk me-bypass peringatan Ngrok
    httpClient.addRequestModifier((request) {
      request.headers['ngrok-skip-browser-warning'] = 'true';
      return request;
    });

    super.onInit();
  }

  // Memanggil endpoint inventory dari backend
  Future<Response> getFashionData() => get('inventory/all');
}
