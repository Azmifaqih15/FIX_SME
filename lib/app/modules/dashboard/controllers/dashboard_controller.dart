import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../routes/app_pages.dart'; // Pastikan path ke app_pages benar
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

  var restockItemsCount = 3.obs;
  var deadStockItemsCount = 2.obs;

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
  var selectedMonth = 'All'.obs; // Filter bulan untuk Bar Chart
  
  bool get hasProfitData => monthlyProfits.any((profit) => profit > 0.0);
  
  // Menggunakan observable list agar UI reaktif saat data kosong atau bertambah
  var transactionHistory = <Map<String, dynamic>>[].obs;

  // 🟢 3. VARIABLE BARU UNTUK TREN & REKOMENDASI HARGA MONGODB
  var priceTrendData = <Map<String, dynamic>>[].obs;
  var recommendationData = <String, dynamic>{}.obs;
  var isLoadingTrend = false.obs;
  var isLoadingRecommendation = false.obs;

  // State untuk filter kategori LineChart
  var selectedCategory = 'All'.obs;
  final List<String> categories = ['All', 'Boxy Fit', 'Fitted', 'Oversize', 'Regular Fit'];

  void changeCategory(String category) {
    selectedCategory.value = category;
  }

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
    print("=== LOAD DASHBOARD ===");
    print("Nama di memori: ${box.read('user_name')}");

    loadUserData();
    fetchDashboardSummary();
    fetchDashboardStats();
    fetchMarketData(); // 🟢 4. JALANKAN PENARIKAN DATA SCRAPING
    
    // Hitung profit untuk Bar Chart
    calculateMonthlyProfits();
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

  int get dynamicGrandTotal {
    return inventoryController.productList.fold(0, (sum, item) => sum + item.qty);
  }

  List<PieChartSectionData> get dynamicPieChartSections {
    int grandTotal = dynamicGrandTotal;
    
    // Penanganan Empty State
    if (grandTotal == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey[300],
          value: 100,
          title: '0%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        )
      ];
    }

    Map<String, int> tempTotals = {
      'Oversize': 0,
      'Boxy Fit': 0,
      'Fitted': 0,
      'Regular Fit': 0
    };

    for (var item in inventoryController.productList) {
      String cat = item.category;
      if (tempTotals.containsKey(cat)) {
        tempTotals[cat] = tempTotals[cat]! + item.qty;
      } else {
        tempTotals['Lainnya'] = (tempTotals['Lainnya'] ?? 0) + item.qty;
      }
    }

    final Map<String, Color> categoryColors = {
      'Oversize': const Color(0xFF10B981),
      'Boxy Fit': const Color(0xFFF59E0B),
      'Fitted': const Color(0xFFDC2626),
      'Regular Fit': const Color(0xFF6B7280),
      'Lainnya': Colors.purple,
    };

    List<PieChartSectionData> sections = [];
    tempTotals.forEach((category, stock) {
      if (stock > 0) {
        double percentage = (stock / grandTotal) * 100;
        Color color = categoryColors[category] ?? Colors.grey;

        sections.add(
          PieChartSectionData(
            color: color,
            value: stock.toDouble(),
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
        );
      }
    });

    return sections;
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
    } catch (e) {
      print("Error mengambil tren harga MongoDB: $e");
    } finally {
      isLoadingTrend(false);
    }
  }

  void fetchRecommendation() async {
    try {
      isLoadingRecommendation(true);
      var data = await _priceService.getPriceRecommendation();
      recommendationData.assignAll(data);
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
      final url = Uri.parse(
          'https://braden-noncrusading-uncarnivorously.ngrok-free.dev/api/v1/dashboard/summary');
      final response = await http.get(url);

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
      // Use standard localhost URL for flutter run or adjust as per environment
      // Assuming ngrok domain was used, we will use the same domain for consistency or standard loopback if needed.
      // I will use the same ngrok base URL used in fetchDashboardSummary.
      final url = Uri.parse('https://braden-noncrusading-uncarnivorously.ngrok-free.dev/api/v1/dashboard/stats');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Convert to double as requested by RxDouble
        if (data['total_inventory'] != null) {
          totalInventory.value = (data['total_inventory'] as num).toDouble();
        }

        if (data['profit_data'] != null) {
          List<dynamic> rawProfits = data['profit_data'];
          monthlyProfits.assignAll(rawProfits.map((e) => (e as num).toDouble()).toList());
        }

        if (data['labels'] != null) {
          List<dynamic> rawLabels = data['labels'];
          monthLabels.assignAll(rawLabels.map((e) => e.toString()).toList());
        }
        
      } else {
        print("Gagal mengambil data stats: ${response.statusCode}");
      }
    } catch (e) {
      print("Error mengambil data stats: $e");
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
