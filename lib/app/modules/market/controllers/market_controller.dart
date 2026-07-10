import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../providers/market_provider.dart';

class PriceMonitorModel {
  final String kategori;
  final int hppInternal;
  final int hargaJualSaatIni;
  final double rekomendasiHargaJual;
  final double rataRataPasar;
  final String statusPersaingan;

  PriceMonitorModel({
    required this.kategori,
    required this.hppInternal,
    required this.hargaJualSaatIni,
    required this.rekomendasiHargaJual,
    required this.rataRataPasar,
    required this.statusPersaingan,
  });

  factory PriceMonitorModel.fromJson(Map<String, dynamic> json) {
    return PriceMonitorModel(
      kategori: json['kategori'] ?? 'Unknown',
      hppInternal: (json['hpp_internal'] ?? 0).toInt(),
      hargaJualSaatIni: (json['harga_jual_saat_ini'] ?? 0).toInt(),
      rekomendasiHargaJual: (json['rekomendasi_harga_jual'] ?? 0).toDouble(),
      rataRataPasar: (json['rata_rata_pasar'] ?? 0).toDouble(),
      statusPersaingan: json['status_persaingan'] ?? 'Unknown',
    );
  }
}

class MarketController extends GetxController {
  late final MarketProvider _provider;

  var monitoringList = <PriceMonitorModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _provider = Get.put(MarketProvider());
    fetchMarketData();
  }

  Future<void> fetchMarketData() async {
    try {
      isLoading(true);
      errorMessage('');
      
      final response = await _provider.getMarketAnalysis();
      
      if (response.statusCode == 200 && response.body != null) {
        print('Raw Response API: ${response.body}');
        var rawData = response.body['data'] ?? [];
        if (rawData is List) {
          var parsedList = <PriceMonitorModel>[];
          for (var item in rawData) {
            try {
              parsedList.add(PriceMonitorModel.fromJson(item));
            } catch (e) {
              print('Error parsing item: $e');
            }
          }
          monitoringList.assignAll(parsedList);
          print('Data berhasil diparsing: ${monitoringList.length}');
        }
      } else {
        errorMessage('Gagal memuat data: ${response.statusCode}');
        Get.snackbar("Error", errorMessage.value);
      }
    } catch (e) {
      errorMessage('Terjadi kesalahan koneksi');
      Get.snackbar("Koneksi Error", "Mohon periksa jaringan internet Anda.");
    } finally {
      isLoading(false);
    }
  }

  void changePage(int index) {
    if (index == 3) return; 
    switch (index) {
      case 0: Get.offAllNamed(Routes.DASHBOARD); break;
      case 1: Get.offAllNamed(Routes.INVENTORY); break;
      case 2: Get.toNamed(Routes.SCAN); break;
      case 4: Get.offAllNamed(Routes.PROFILE); break;
    }
  }
}
