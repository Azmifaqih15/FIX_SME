import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();

  // Variabel untuk memunculkan efek loading saat tombol ditekan
  var isLoading = false.obs;

  void sendOtp() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      // Simulasi proses API (jeda 2 detik seolah-olah mengirim email)
      await Future.delayed(const Duration(seconds: 2));

      isLoading.value = false;

      // Memunculkan notifikasi sukses
      Get.snackbar(
        "OTP Sent",
        "Silakan periksa kotak masuk email Anda.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      // TODO: Nanti kode ini diaktifkan untuk pindah ke halaman Input OTP
      // Get.toNamed('/verify-otp', arguments: {'email': emailCtrl.text});
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }
}
