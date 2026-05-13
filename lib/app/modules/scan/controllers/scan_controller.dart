import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart'; // Sesuaikan path rute Anda

class ScanController extends GetxController {
  final searchController = TextEditingController();
  
  var recentScans = [
    {
      "name": "Precision Hex Bolt M8",
      "sku": "SKU: 8321023-F",
      "qty": "+24",
      "time": "2 mins ago",
      "color": Colors.green
    },
    {
      "name": "Carbon Filter Module",
      "sku": "SKU: DF-1021-Y",
      "qty": "-2",
      "time": "5 mins ago",
      "color": Colors.red
    },
  ].obs;

  // --- FUNGSI PINDAH HALAMAN ---
  void changePage(int index) {
    if (index == 2) return; // Tetap di Scan
    switch (index) {
      case 0: Get.offAllNamed(Routes.DASHBOARD); break;
      case 1: Get.offAllNamed(Routes.INVENTORY); break;
      case 3: Get.offAllNamed(Routes.MARKET); break;
      case 4: Get.offAllNamed(Routes.PROFILE); break;
    }
  }

  void onStockIn() {
    Get.snackbar("Stock In", "Siap memproses barang masuk");
  }

  void onStockOut() {
    Get.snackbar("Stock Out", "Siap memproses barang keluar");
  }
}