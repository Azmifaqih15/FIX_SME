import 'package:get/get.dart';

import '../controllers/business_info_controller.dart';

class BusinessInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessInfoController>(
      () => BusinessInfoController(),
    );
  }
}
