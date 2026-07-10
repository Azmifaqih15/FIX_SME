import 'package:get/get.dart';
// Pastikan path ini benar sesuai struktur folder Anda
import '../controllers/market_controller.dart'; 

class MarketBinding extends Bindings {
  @override
  void dependencies() {
    // lazyPut memastikan memory efisien (controller dibuat saat halaman dibuka)
    Get.lazyPut<MarketController>(
      () => MarketController(),
    );
  }
}
