import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // State untuk menyembunyikan/menampilkan isi teks password (ikon mata)
  var isObscureNew = true.obs;
  var isObscureConfirm = true.obs;

  var isLoading = false.obs;
  var userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Menangkap email yang dikirim dari halaman verifikasi OTP sebelumnya
    if (Get.arguments != null && Get.arguments['email'] != null) {
      userEmail.value = Get.arguments['email'];
    }
  }

  Future<void> submitResetPassword() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      try {
        // TODO: Ganti bagian ini dengan pemanggilan API ke backend (AuthService)
        // Contoh: await authService.resetPassword(userEmail.value, newPasswordCtrl.text);

        // --- SIMULASI LOADING SEMENTARA ---
        await Future.delayed(const Duration(seconds: 2));

        Get.snackbar(
          "Sukses",
          "Kata sandi Anda berhasil diperbarui. Silakan login kembali.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
        );

        // Menghapus semua riwayat halaman (Input Email, OTP, Reset) dan kembali ke Login
        Get.offAllNamed('/login');
      } catch (e) {
        Get.snackbar(
          "Gagal",
          "Terjadi kesalahan saat menyimpan password baru.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}
