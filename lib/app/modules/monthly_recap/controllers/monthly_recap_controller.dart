import 'package:get/get.dart';
import 'package:smart_sme_app/app/modules/inventory/controllers/inventory_controller.dart';
import 'package:smart_sme_app/app/modules/activity_log/controllers/activity_log_controller.dart';
import 'package:smart_sme_app/app/modules/inventory/controllers/inventory_controller.dart' as inv;

class MonthlyRecapController extends GetxController {
  var isLoading = true.obs;
  
  var totalProfit = 0.0.obs;
  var bestCategory = '-'.obs;
  var lowStock = 0.obs;
  var deadStockCount = 0.obs;
  
  var deadStockList = <inv.Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    calculateMonthlyRecap();
  }

  Future<void> calculateMonthlyRecap() async {
    try {
      isLoading.value = true;
      
      // Mengambil instance controller (buat jika belum ada)
      final inventoryController = Get.isRegistered<InventoryController>() 
          ? Get.find<InventoryController>() 
          : Get.put(InventoryController());
          
      final activityController = Get.isRegistered<ActivityLogController>()
          ? Get.find<ActivityLogController>()
          : Get.put(ActivityLogController());

      // Tunggu data ditarik jika masih kosong
      if (inventoryController.productList.isEmpty) {
        await inventoryController.fetchInventory();
      }
      if (activityController.activityLogs.isEmpty) {
        await activityController.fetchLogs();
      }

      // 1. Logika Pengambilan Data (Filter 1 Bulan Terakhir)
      DateTime sebulanLalu = DateTime.now().subtract(const Duration(days: 30));

      // Filter log transaksi barang keluar setelah sebulanLalu
      var recentOutLogs = activityController.activityLogs.where((log) {
        return log.createdAt.isAfter(sebulanLalu) && log.actionType == 'SCAN_OUT';
      }).toList();

      // 2. Kalkulasi 4 Metrik Utama
      double tempTotalProfit = 0.0;
      Map<String, int> categorySales = {};

      for (var log in recentOutLogs) {
        // Ekstrak nama produk dari description (karena model ActivityLog tidak menyimpan qty & modal)
        // Format deskripsi: "Scanned out product: Nama Produk"
        String productName = log.description.replaceAll("Scanned out product: ", "").trim();
        
        var productInfo = inventoryController.productList.firstWhereOrNull(
          (p) => p.name == productName || p.sku == productName
        );
        
        if (productInfo != null) {
          // Asumsi qty terjual per log = 1 (karena API log hanya mencatat event out tanpa spesifik qty)
          // Asumsi harga modal = 70% dari harga jual produk (karena tidak ada field Harga Modal)
          int qtyTerjual = 1; 
          double hargaJual = productInfo.price.toDouble();
          double hargaModal = hargaJual * 0.7; 
          
          tempTotalProfit += ((hargaJual - hargaModal) * qtyTerjual);
          
          categorySales[productInfo.category] = (categorySales[productInfo.category] ?? 0) + qtyTerjual;
        }
      }

      totalProfit.value = tempTotalProfit;

      // Kategori Terlaris (Berdasarkan value qty terjual)
      if (categorySales.isNotEmpty) {
        var topCat = categorySales.entries.reduce((a, b) => a.value > b.value ? a : b);
        bestCategory.value = topCat.key; // Sudah mengembalikan nama kategori (misal: "Oversize")
      } else {
        bestCategory.value = "-";
      }

      // Low Stock (Misal qty > 0 dan <= 10)
      lowStock.value = inventoryController.productList.where((p) => p.qty > 0 && p.qty <= 10).length;

      // Dead Stock
      // Sesuai dengan status yang ada di inventory, kita ambil produk yang statusnya 'DEAD STOCK'
      // agar sinkron dan tidak false-positive saat belum ada transaksi penjualan sama sekali.
      var deadStocks = inventoryController.productList.where((p) {
        return p.status.toUpperCase() == 'DEAD STOCK' || p.status.toUpperCase() == 'DEAD_STOCK';
      }).toList();
      
      deadStockCount.value = deadStocks.length;
      deadStockList.assignAll(deadStocks);

    } catch (e) {
      print("Error calculateMonthlyRecap: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
