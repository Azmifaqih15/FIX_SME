import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Menginisialisasi ProfileController secara Lazy (hanya saat dibutuhkan)
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
  }
}
