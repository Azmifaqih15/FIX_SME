import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import 'package:smart_sme_app/app/data/services/price_service.dart';

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
      kategori: json['kategori'] ?? '-',
      hppInternal: (json['hpp_internal'] ?? 0).toInt(),
      hargaJualSaatIni: (json['harga_jual_saat_ini'] ?? 0).toInt(),
      rekomendasiHargaJual: (json['rekomendasi_harga_jual'] ?? 0).toDouble(),
      rataRataPasar: (json['rata_rata_pasar'] ?? 0).toDouble(),
      statusPersaingan: json['status'] ?? json['status_persaingan'] ?? '-',
    );
  }
}

class MarketController extends GetxController {
  late final PriceService _priceService;

  var monitoringList = <PriceMonitorModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _priceService = PriceService();
    fetchMarketData();
  }

  Future<void> fetchMarketData() async {
    try {
      isLoading(true);
      errorMessage('');
      
      final rawData = await _priceService.getPriceRecommendation();
      
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
      
    } catch (e) {
      print('Error Market Data: $e');
      errorMessage('Terjadi kesalahan koneksi atau data belum tersedia.');
      Get.snackbar("Koneksi Error", "Mohon periksa jaringan internet Anda atau pastikan data ada.");
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
