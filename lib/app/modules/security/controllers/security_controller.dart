import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SecurityController extends GetxController {
  final box = GetStorage();
  final formKey = GlobalKey<FormState>();

  // --- State untuk Toggle Keamanan ---
  var isFaceIdEnabled = false.obs;
  var isTwoFactorEnabled = false.obs;

  // --- State untuk Form Ganti Password ---
  var obsCurrent = true.obs;
  var obsNew = true.obs;
  var obsConfirm = true.obs;

  final currentPwdCtrl = TextEditingController();
  final newPwdCtrl = TextEditingController();
  final confirmPwdCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Membaca status preferensi keamanan dari storage HP
    isFaceIdEnabled.value = box.read('use_face_id') ?? false;
    isTwoFactorEnabled.value = box.read('use_2fa') ?? false;
  }

  // --- Fungsi Toggle ---
  void toggleFaceId(bool value) {
    isFaceIdEnabled.value = value;
    box.write('use_face_id', value);

    Get.snackbar(
      "Security Updated",
      value ? "Face ID Login Enabled." : "Face ID Login Disabled.",
      backgroundColor: value ? Colors.green[50] : Colors.orange[50],
      colorText: value ? Colors.green[900] : Colors.orange[900],
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  void toggleTwoFactor(bool value) {
    isTwoFactorEnabled.value = value;
    box.write('use_2fa', value);
  }

  // --- Fungsi Ganti Password ---
  void changePassword() {
    if (formKey.currentState!.validate()) {
      // Logika API untuk update password di backend FastAPI Anda nanti ditaruh di sini

      Get.back(); // Tutup halaman
      Get.snackbar(
        "Success",
        "Your password has been changed successfully.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  void onClose() {
    currentPwdCtrl.dispose();
    newPwdCtrl.dispose();
    confirmPwdCtrl.dispose();
    super.onClose();
  }
}
