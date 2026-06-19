import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart'; // Pastikan path ke app_pages benar

class DashboardController extends GetxController {
  final box = GetStorage();

  var userName = "Alex".obs;
  var totalItems = "1,248".obs;
  var lowStock = 12.obs;
  var deadStock = 45.obs;
  var potentialProfit = "\$14.3k".obs;

  var restockItemsCount = 3.obs;
  var deadStockItemsCount = 2.obs;

  var priceAlerts = [
    {
      "name": "Kemeja Flanel L",
      "marketAvg": "Rp 145.000",
      "yourPrice": "Rp 155.000",
      "diff": "+6% Above",
      "status": "High"
    },
    {
      "name": "Sepatu Sneakers V2",
      "marketAvg": "Rp 210.000",
      "yourPrice": "Rp 200.000",
      "diff": "-5% Below",
      "status": "Safe"
    },
  ].obs;

  // --- FUNGSI NAVIGASI OTOMATIS ---
  @override
  void onInit() {
    super.onInit();
    final storedName = box.read('name');
    if (storedName != null && storedName is String && storedName.isNotEmpty) {
      userName.value = storedName;
    }
  }

  void changePage(int index) {
    if (index == 0) return; // Tetap di Dashboard
    switch (index) {
      case 1:
        Get.offAllNamed(Routes.INVENTORY);
        break;
      case 2:
        Get.offAllNamed(Routes.SCAN);
        break;
      case 3:
        Get.offAllNamed(Routes.MARKET);
        break;
      case 4:
        Get.offAllNamed(Routes.PROFILE);
        break;
    }
  }

  void recalculateMargins() {
    Get.snackbar("AI Engine",
        "Menghitung ulang margin berdasarkan harga pasar terbaru...");
  }
}
