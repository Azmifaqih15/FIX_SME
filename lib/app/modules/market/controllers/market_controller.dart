import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class MarketController extends GetxController {
  final marketHealth = "Competitive".obs;
  final marketTrend = "+1.5% High Demand".obs;
  final priceGapsCount = 4.obs;

  // Data disesuaikan dengan koleksi T-Shirt di Inventory
  final trackedProducts = <Map<String, dynamic>>[
    {
      "name": "Heavyweight Oversize Tee",
      "status": "Competitive",
      "shop_price": "Rp 150k",
      "modal_price": "Rp 85k",
      "shopee_price": "Rp 155k",
      "tokopedia_price": "Rp 152k",
      "trend": "Match Market",
    },
    {
      "name": "Streetwear Boxy Tee",
      "status": "Price Gap Detected",
      "shop_price": "Rp 175k",
      "modal_price": "Rp 95k",
      "shopee_price": "Rp 145k",
      "tokopedia_price": "Rp 149k",
      "trend": "Market Drop 15%",
    },
    {
      "name": "Essential Regular Fit",
      "status": "Healthy Margin",
      "shop_price": "Rp 120k",
      "modal_price": "Rp 65k",
      "shopee_price": "Rp 125k",
      "tokopedia_price": "Rp 122k",
      "trend": "Stable",
    },
    {
      "name": "Athletic Fitted Tee",
      "status": "Dead Stock",
      "shop_price": "Rp 110k",
      "modal_price": "Rp 60k",
      "shopee_price": null,
      "tokopedia_price": null,
      "trend": "Clearance Suggestion",
    }
  ].obs;

  void changePage(int index) {
    if (index == 3) return; 
    switch (index) {
      case 0: Get.offAllNamed(Routes.DASHBOARD); break;
      case 1: Get.offAllNamed(Routes.INVENTORY); break;
      case 2: Get.toNamed(Routes.SCAN); break;
      case 4: Get.offAllNamed(Routes.PROFILE); break;
    }
  }

  void applyBulkAdjustments() {
    Get.snackbar(
      "AI Price Sync", 
      "Successfully adjusted T-Shirt prices to remain competitive.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}