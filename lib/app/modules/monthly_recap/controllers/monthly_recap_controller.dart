import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:smart_sme_app/app/data/api_config.dart';

class MonthlyRecapController extends GetxController {
  var isLoading = true.obs;
  
  var totalProfit = 0.obs;
  var bestCategory = '-'.obs;
  var lowStock = 0.obs;
  var deadStock = 0.obs;
  
  var deadStockList = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMonthlyRecap();
  }

  Future<void> fetchMonthlyRecap() async {
    try {
      isLoading.value = true;
      final fullUrl = '${ApiConfig.BASE_URL}/analytics/monthly-recap';
      ApiConfig.logNetwork(fullUrl);
      final response = await http.get(Uri.parse(fullUrl), headers: {'ngrok-skip-browser-warning': 'true'});
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        totalProfit.value = data['total_profit'] ?? 0;
        bestCategory.value = data['top_selling_item'] != null ? data['top_selling_item']['name'] : '-';
        lowStock.value = data['low_stock'] ?? 0;
        deadStock.value = data['dead_stock'] ?? 0;
        
        if (data['dead_stock_list'] != null) {
          deadStockList.assignAll(data['dead_stock_list']);
        }
      }
    } catch (e) {
      print("Error fetchMonthlyRecap: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
