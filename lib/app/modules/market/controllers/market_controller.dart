import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../routes/app_pages.dart'; // Pastikan import rute benar

class MarketController extends GetxController {
  final marketHealth = "Stable".obs;
  final marketTrend = "+2.4% vs last week".obs;
  final priceGapsCount = 12.obs;

  final trackedProducts = <Map<String, dynamic>>[
    {
      "name": "Wireless Pro Headphones",
      "status": "Competitive",
      "shop_price": "Rp 1.250k",
      "modal_price": "Rp 950k",
      "shopee_price": "Rp 1.280k",
      "tokopedia_price": "Rp 1.265k",
      "trend": "Match Market",
    },
    {
      "name": "Smart Fit Gen 5",
      "status": "Price Gap Detected",
      "shop_price": "Rp 2.100k",
      "modal_price": "Rp 1.600k",
      "shopee_price": "Rp 1.850k",
      "tokopedia_price": "Rp 1.890k",
      "trend": "Discount 12%",
    },
    {
      "name": "Power Vault 20k",
      "status": "Dead Stock",
      "shop_price": "Rp 450k",
      "modal_price": "Rp 380k",
      "shopee_price": null,
      "tokopedia_price": null,
      "trend": "Clearance Suggestion",
    }
  ].obs;

  // --- FUNGSI NAVIGASI OTOMATIS ---
  void changePage(int index) {
    if (index == 3) return; // Tetap di Market
    switch (index) {
      case 0: Get.offAllNamed(Routes.DASHBOARD); break;
      case 1: Get.offAllNamed(Routes.INVENTORY); break;
      case 2: Get.offAllNamed(Routes.SCAN); break;
      case 4: Get.offAllNamed(Routes.PROFILE); break;
    }
  }

  void applyBulkAdjustments() {
    Get.snackbar(
      "AI Success", 
      "Successfully adjusted 12 product prices to match market trends.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}