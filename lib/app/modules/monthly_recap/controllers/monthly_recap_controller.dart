import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:smart_sme_app/app/data/api_config.dart';
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
      
      // Mengambil data langsung dari endpoint dashboard summary agar selalu sinkron
      final url = Uri.parse('${ApiConfig.BASE_URL}/dashboard/summary');
      final response = await http.get(url, headers: ApiConfig.getHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        lowStock.value = data['low_stock'] ?? 0;
        deadStockCount.value = data['dead_stock'] ?? 0;
        
        final profit = data['potential_profit'] ?? 0;
        totalProfit.value = profit.toDouble();
        
        bestCategory.value = data['best_seller']?['name'] ?? '-';
        
        // Dead stock items
        if (data['dead_stock_items'] != null) {
          List<dynamic> items = data['dead_stock_items'];
          // Kita perlu mengonversi Map json ini ke model Product jika memungkinkan.
          // Atau kita ambil langsung dari InventoryController seperti sebelumnya
          final inventoryController = Get.isRegistered<InventoryController>() 
              ? Get.find<InventoryController>() 
              : Get.put(InventoryController());
              
          if (inventoryController.productList.isEmpty) {
            await inventoryController.fetchInventory();
          }
          
          var deadStocks = inventoryController.productList.where((p) {
            return p.status.toUpperCase() == 'DEAD STOCK' || p.status.toUpperCase() == 'DEAD_STOCK';
          }).toList();
          
          deadStockList.assignAll(deadStocks);
        }
      } else {
        print("Gagal mengambil data rekap bulanan: ${response.statusCode}");
      }
    } catch (e) {
      print("Error calculateMonthlyRecap: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
