import 'package:get/get.dart';
import '../controllers/auto_face_login_controller.dart';

class AutoFaceLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AutoFaceLoginController>(
      () => AutoFaceLoginController(),
    );
  }
}
