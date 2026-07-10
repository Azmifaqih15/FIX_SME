import 'package:get/get.dart';
import '../models/fashion_model.dart';
import '../providers/fashion_provider.dart';

class FashionController extends GetxController {
  late final FashionProvider _provider;

  var fashionList = <FashionModel>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Menggunakan Get.put() agar onInit() di FashionProvider otomatis dipanggil GetX
    _provider = Get.put(FashionProvider());
    fetchData();
  }

  void fetchData() async {
    try {
      isLoading(true);
      final response = await _provider.getFashionData();
      
      if (response.statusCode == 200 && response.body != null) {
        var rawData = response.body['data'];
        if (rawData != null && rawData is List) {
          fashionList.assignAll(rawData.map((e) => FashionModel.fromJson(e)).toList());
        }
      } else {
        Get.snackbar("Error", "Gagal memuat data: ${response.statusCode}");
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar("Error", "Terjadi kesalahan koneksi saat memuat data");
    } finally {
      isLoading(false);
    }
  }
}