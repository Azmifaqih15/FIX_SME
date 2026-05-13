import 'package:get/get.dart';
import '../../../routes/app_pages.dart'; 

class ProfileController extends GetxController {
  var name = "Alexandria Smith".obs;
  var email = "alex.smith@smart-sme.ai".obs;
  var role = "Infrastructure Manager".obs;

  void changePage(int index) {
    if (index == 4) return; 
    switch (index) {
      case 0: Get.offAllNamed(Routes.DASHBOARD); break;
      case 1: Get.offAllNamed(Routes.INVENTORY); break;
      case 2: Get.offAllNamed(Routes.SCAN); break;
      case 3: Get.offAllNamed(Routes.MARKET); break;
    }
  }

  void logout() {
    Get.offAllNamed(Routes.LOGIN);
  }

  void editProfile() {
    Get.snackbar("Edit Profile", "Fitur edit profil akan segera hadir");
  }
}