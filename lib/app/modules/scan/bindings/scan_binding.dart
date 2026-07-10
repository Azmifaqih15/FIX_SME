import 'package:get/get.dart';

import '../controllers/scan_controller.dart';

class ScanBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut memastikan controller hanya dibuat saat halaman benar-benar diakses
    Get.lazyPut<ScanController>(
      () => ScanController(),
    );
  }
}
