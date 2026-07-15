import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../routes/app_pages.dart';
import 'package:smart_sme_app/app/data/api_config.dart';
import 'package:smart_sme_app/app/data/services/price_service.dart'; // 🟢 1. SESUAIKAN IMPORT PRICE SERVICE
import 'package:smart_sme_app/app/modules/inventory/controllers/inventory_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardController extends GetxController {
  final box = GetStorage();
  final PriceService _priceService =
      PriceService(); // 🟢 2. INISIALISASI PRICE SERVICE

  var userName = "User".obs;
  var userPhoto = "".obs;
  var totalItems = 0.obs;
  var lowStock = 0.obs;
  var deadStock = 0.obs;
  var potentialProfit = "Rp 0".obs;
  var bestSellerName = "Tidak Ada".obs;
  var deadStockItems = <dynamic>[].obs;

  // New variables for Dashboard Stats API
  var totalInventory = 0.0.obs;
  var monthLabels = <String>[].obs;

  // State untuk Pie Chart (Donut) Internal Inventory
  var inventoryList = <Map<String, dynamic>>[].obs;
  var categoryTotals = <String, int>{}.obs;
  var totalGrandStok = 0.obs;
  
  // State untuk Bar Chart (Performa Penjualan 12 Bulan)
  var monthlyProfits = List<double>.filled(12, 0.0).obs;
  var selectedMonthIndex = (-1).obs; // Indeks batang yang dipilih
  var selectedMonth = 'All'.obs; // Filter bulan string (lama)
  var selectedMonthNum = DateTime.now().month.obs; // Filter bulan reaktif (baru)
  
  bool get hasProfitData {
    if (selectedMonthNum.value >= 1 && selectedMonthNum.value <= 12) {
      return monthlyProfits[selectedMonthNum.value - 1] > 0.0;
    }
    return monthlyProfits.any((profit) => profit > 0.0);
  }
  
  void setSalesMonthFilter(int month) {
    selectedMonthNum.value = month;
  }
  
  // Menggunakan observable list agar UI reaktif saat data kosong atau bertambah
  var transactionHistory = <Map<String, dynamic>>[].obs;

  // 🟢 3. VARIABLE BARU UNTUK TREN & REKOMENDASI HARGA MONGODB
  var priceTrendData = <Map<String, dynamic>>[].obs;
  var trendDates = <String>[].obs;
  var trendSpotsByCategory = <String, List<FlSpot>>{}.obs;
  var recommendationData = <String, dynamic>{}.obs;
  var isLoadingTrend = false.obs;
  var isLoadingRecommendation = false.obs;

  // State untuk filter kategori LineChart
  RxString selectedCategoryFilter = 'All'.obs;
  final List<String> categories = ['All', 'Boxy Fit', 'Fitted', 'Oversize', 'Regular Fit'];

  void setCategoryFilter(String category) {
    selectedCategoryFilter.value = category;
  }

  // Menampung alert harga, jika ada datanya dari backend.
  var priceAlerts = <Map<String, dynamic>>[].obs;

  // --- FUNGSI NAVIGASI OTOMATIS ---
  @override
  void onInit() {
    super.onInit();
    print("=== LOAD DASHBOARD ===");
    print("Nama di memori: ${box.read('user_name')}");

    loadUserData();
    fetchDashboardSummary();
    fetchDashboardStats();
    fetchMonthlyProfit(); // 🟢 5. FETCH MONTHLY PROFIT
    fetchMarketData(); // 🟢 4. JALANKAN PENARIKAN DATA SCRAPING
    
    // Hitung profit untuk Bar Chart (cadangan jika tidak dari backend)
    calculateMonthlyProfits();
    
    // Binding agar chart recalculate tiap produk inventory berubah
    ever(inventoryController.productList, (_) {
      calculateCategoryChart();
    });
    // Panggil manual pertama kali
    calculateCategoryChart();
  }

  // Menambahkan transaksi baru secara real-time (contoh dari Scan Out)
  void addTransaction(dynamic transaction) {
    // Kita gunakan dynamic/Map agar fleksibel jika menggunakan TransactionModel nanti
    // Contoh format: {'createdAt': '2026-07-09T10:00:00Z', 'profit': 15.0}
    Map<String, dynamic> newTx = transaction is Map ? Map<String, dynamic>.from(transaction) : {};
    
    // Jika TransactionModel memiliki method toJson(), bisa gunakan: 
    // newTx = transaction.toJson();
    
    if (newTx.isNotEmpty) {
      transactionHistory.add(newTx);
      calculateMonthlyProfits(); // Hitung ulang grafik real-time
    }
  }

  void calculateMonthlyProfits() {
    // Reset ke 0 agar aman dari state sebelumnya (Tahan banting)
    List<double> profits = List.filled(12, 0.0);
    
    // Jika data kosong, langsung update UI dengan nilai 0.0 (Tahan banting)
    if (transactionHistory.isEmpty) {
      monthlyProfits.assignAll(profits);
      return;
    }

    for (var tx in transactionHistory) {
      if (tx['createdAt'] != null) {
        try {
          DateTime date = DateTime.parse(tx['createdAt'].toString());
          int monthIndex = date.month - 1; // 0 untuk Januari, 11 untuk Desember
          
          if (monthIndex >= 0 && monthIndex < 12) {
            // Ambil potentialProfit jika ada, jika tidak fallback ke profit biasa
            double profitVal = 0.0;
            if (tx.containsKey('potentialProfit')) {
              profitVal = (tx['potentialProfit'] as num).toDouble();
            } else if (tx.containsKey('profit')) {
              profitVal = (tx['profit'] as num).toDouble();
            }
            profits[monthIndex] += profitVal;
          }
        } catch (e) {
          print("Error memparsing tanggal transaksi: $e");
        }
      }
    }
    
    monthlyProfits.assignAll(profits);
  }

  // Fungsi interaksi Bar Chart: Mengambil detail profit di bulan tertentu
  Map<String, dynamic> getDetailPerMonth(int monthIndex) {
    List<Map<String, dynamic>> filteredTxs = [];
    double totalProfit = 0.0;
    
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    if (monthIndex < 0 || monthIndex >= 12) {
      return {
        'month_name': 'Unknown',
        'total_profit': 0.0,
        'transactions': [],
      };
    }

    if (transactionHistory.isNotEmpty) {
      for (var tx in transactionHistory) {
        if (tx['createdAt'] != null) {
          try {
            DateTime date = DateTime.parse(tx['createdAt'].toString());
            if (date.month - 1 == monthIndex) {
              filteredTxs.add(tx);
              double profitVal = 0.0;
              if (tx.containsKey('potentialProfit')) {
                profitVal = (tx['potentialProfit'] as num).toDouble();
              } else if (tx.containsKey('profit')) {
                profitVal = (tx['profit'] as num).toDouble();
              }
              totalProfit += profitVal;
            }
          } catch (e) {
            print("Error filtering transaction: $e");
          }
        }
      }
    }

    return {
      'month_name': months[monthIndex],
      'total_profit': totalProfit,
      'transactions': filteredTxs,
    };
  }

  // ==========================================
  // ARSITEKTUR GETX REAKTIF UNTUK DONUT CHART
  // ==========================================
  
  InventoryController get inventoryController {
    if (Get.isRegistered<InventoryController>()) {
      return Get.find<InventoryController>();
    }
    return Get.put(InventoryController());
  }

  // State reaktif baru
  var stockByCategory = <String, int>{}.obs;
  var totalStock = 0.obs;
  var chartSections = <PieChartSectionData>[].obs;

  void calculateCategoryChart() {
    Map<String, int> tempStockByCategory = {};
    int tempTotalStock = 0;
    
    for (var item in inventoryController.productList) {
      // Normalisasi kategori ('BOXY FIT' dan 'boxy fit' akan jadi 'Boxy fit' dsb)
      String category = item.category.toLowerCase().trim();
      if (category.isEmpty) category = 'lainnya';
      
      // Rapikan jadi Kapital di awal
      category = category.split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');

      tempStockByCategory[category] = (tempStockByCategory[category] ?? 0) + item.qty;
      tempTotalStock += item.qty;
    }

    stockByCategory.assignAll(tempStockByCategory);
    totalStock.value = tempTotalStock;

    // Palette warna elegan
    final List<Color> palette = [
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFDC2626), // Red
      const Color(0xFF6B7280), // Gray
      const Color(0xFF4F46E5), // Indigo
      const Color(0xFF0EA5E9), // Sky Blue
      const Color(0xFF8B5CF6), // Violet
      Colors.pink,
      Colors.teal,
    ];

    List<PieChartSectionData> sections = [];
    int colorIndex = 0;

    if (tempTotalStock == 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.grey[300],
          value: 100,
          title: '0%',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
        )
      );
    } else {
      tempStockByCategory.forEach((category, stock) {
        if (stock > 0) {
          double percentage = (stock / tempTotalStock) * 100;
          Color color = palette[colorIndex % palette.length];
          
          sections.add(
            PieChartSectionData(
              color: color,
              value: stock.toDouble(),
              title: '${percentage.toStringAsFixed(1)}%',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            )
          );
          colorIndex++;
        }
      });
    }

    chartSections.assignAll(sections);
  }

  // Mengambil Tren Harga & Rekomendasi
  void fetchMarketData() async {
    fetchPriceTrend();
    fetchRecommendation();
  }

  void fetchPriceTrend() async {
    try {
      isLoadingTrend(true);
      // Mengambil 30 data terakhir (asumsi 4 kategori per bulan = data untuk ~7 bulan terakhir)
      var data = await _priceService.getPriceTrend(limit: 30);

      // Membalikkan urutan (reverse) agar kronologinya pas dari bulan terlama ke terbaru
      priceTrendData.assignAll(data.reversed.toList());
      _processTrendData();
    } catch (e) {
      print("Error mengambil tren harga MongoDB: $e");
    } finally {
      isLoadingTrend(false);
    }
  }

  void _processTrendData() {
    if (priceTrendData.isEmpty) return;

    // 1. Grouping data mentah ke dalam kategori
    Map<String, List<Map<String, dynamic>>> itemsByCat = {};
    for (String cat in categories) {
      if (cat == 'All') continue;
      itemsByCat[cat] = [];
    }

    // Pisahkan item ke masing-masing array kategori
    // priceTrendData sudah di-reverse (dari lama ke baru)
    for (var item in priceTrendData) {
      String cat = item['kategori']?.toString() ?? item['category']?.toString() ?? '';
      
      // Normalisasi nama kategori (cocokkan dengan array categories)
      String normalizedCat = categories.firstWhere(
        (c) => c.toLowerCase() == cat.toLowerCase(),
        orElse: () => '',
      );

      if (normalizedCat.isNotEmpty && normalizedCat != 'All') {
        itemsByCat[normalizedCat]!.add(item);
      }
    }
    
    // 2. Mapping ke FlSpot dengan index sekuensial (0, 1, 2, ...) agar tidak menumpuk di 1 X
    Map<String, List<FlSpot>> spotsByCat = {};
    int maxDataLength = 0;

    for (String cat in itemsByCat.keys) {
      List<FlSpot> spots = [];
      var items = itemsByCat[cat]!;
      
      if (items.length > maxDataLength) {
        maxDataLength = items.length;
      }
      
      for (int i = 0; i < items.length; i++) {
        num harga = items[i]['rata_rata_pasar'] ?? items[i]['price'] ?? items[i]['harga'] ?? 0;
        spots.add(FlSpot(i.toDouble(), harga.toDouble()));
      }
      spotsByCat[cat] = spots;
    }

    // Generate label sumbu X (Hanya label generik atau ambil dari data jika ada)
    List<String> labels = [];
    for (int i = 0; i < maxDataLength; i++) {
      labels.add("Data ${i + 1}");
    }
    trendDates.assignAll(labels);

    trendSpotsByCategory.assignAll(spotsByCat);
  }

  void fetchRecommendation() async {
    try {
      isLoadingRecommendation(true);
      var data = await _priceService.getPriceRecommendation();
      if (data.isNotEmpty) {
        // Ambil data pertama saja untuk ditampilkan di Dashboard
        recommendationData.assignAll(data.first);
      } else {
        recommendationData.clear();
      }
    } catch (e) {
      print("Error mengambil data rekomendasi MongoDB: $e");
    } finally {
      isLoadingRecommendation(false);
    }
  }

  String formatRupiah(int number) {
    String str = number.toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      count++;
      result = str[i] + result;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return 'Rp $result';
  }

  Future<void> fetchDashboardSummary() async {
    try {
      final url = Uri.parse('${ApiConfig.BASE_URL}/dashboard/summary');
      final response = await http.get(url, headers: ApiConfig.getHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        totalItems.value = data['total_items'] ?? 0;
        lowStock.value = data['low_stock'] ?? 0;
        deadStock.value = data['dead_stock'] ?? 0;

        final profit = data['potential_profit'] ?? 0;
        potentialProfit.value = formatRupiah(profit.toInt());

        bestSellerName.value = data['best_seller']?['name'] ?? 'Tidak Ada';
        if (data['dead_stock_items'] != null) {
          deadStockItems.value = data['dead_stock_items'];
        }
      } else {
        print("Gagal mengambil data dashboard: ${response.statusCode}");
      }
    } catch (e) {
      print("Error mengambil data dashboard: $e");
    }
  }

  Future<void> fetchDashboardStats() async {
    try {
      final url = Uri.parse('${ApiConfig.BASE_URL}/dashboard/stats');
      final response = await http.get(url, headers: ApiConfig.getHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['total_inventory'] != null) {
          totalInventory.value = (data['total_inventory'] as num).toDouble();
        }
      }
    } catch (e) {
      print("Error mengambil data stats: $e");
    }
  }

  Future<void> fetchMonthlyProfit() async {
    try {
      final url = Uri.parse('${ApiConfig.BASE_URL}/inventory/monthly-profit');
      final response = await http.get(url, headers: ApiConfig.getHeaders());
      
      print('Data Profit JSON: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<double> newProfits = List.filled(12, 0.0); // Aman: default 0.0

        if (data is List) {
          for (var item in data) {
            int? month = item['month'];
            // Tangkap key total_profit, profit, atau total_revenue
            num? profit = item['total_profit'] ?? item['profit'] ?? item['total_revenue'];
            
            if (month != null && month >= 1 && month <= 12 && profit != null) {
              newProfits[month - 1] = profit.toDouble();
            }
          }
        }
        monthlyProfits.assignAll(newProfits);
      } else {
        print("Gagal mengambil monthly profit: ${response.statusCode}");
      }
    } catch (e) {
      print("Error mengambil monthly profit: $e");
    }
  }

  String formatProfit(double value) {
    if (value >= 1000000) {
      double result = value / 1000000;
      // If it's a whole number, don't show decimals (e.g. 15.0 -> 15)
      if (result == result.truncateToDouble()) {
        return '${result.toInt()}jt';
      }
      return '${result.toStringAsFixed(1)}jt';
    } else if (value >= 1000) {
      double result = value / 1000;
      if (result == result.truncateToDouble()) {
        return '${result.toInt()}k';
      }
      return '${result.toStringAsFixed(1)}k';
    }
    return value.toInt().toString();
  }

  Future<void> loadUserData() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final storedName = box.read('user_name');
    if (storedName != null &&
        storedName is String &&
        storedName.trim().isNotEmpty) {
      userName.value = storedName;
    }

    final storedPhoto = box.read('user_photo');
    if (storedPhoto != null &&
        storedPhoto is String &&
        storedPhoto.trim().isNotEmpty) {
      userPhoto.value = storedPhoto;
    }

    update();
  }

  void changePage(int index) {
    if (index == 0) return;
    switch (index) {
      case 1:
        Get.offAllNamed(Routes.INVENTORY);
        break;
      case 2:
        Get.toNamed(Routes.SCAN);
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
