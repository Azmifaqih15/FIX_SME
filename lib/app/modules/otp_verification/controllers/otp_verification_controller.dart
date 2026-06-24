import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_sme_app/app/data/services/auth_service.dart';

class OtpVerificationController extends GetxController {
  late AuthService authService;

  var name = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;

  // 🟢 Tambahan variabel untuk mendeteksi apakah ini alur Lupa Password
  var isForgotPassword = false.obs;

  final otpController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    try {
      authService = Get.find<AuthService>();
    } catch (e) {
      authService = Get.put(AuthService());
    }

    if (Get.arguments != null && Get.arguments is Map) {
      name.value = Get.arguments['name'] ?? '';
      email.value = Get.arguments['email'] ?? '';
      password.value = Get.arguments['password'] ?? '';

      // 🟢 Tangkap argumen isForgotPassword jika ada
      isForgotPassword.value = Get.arguments['isForgotPassword'] ?? false;
    }
  }

  // 🟢 Fungsi utama yang akan dipanggil oleh tombol di View
  void submitOtp() {
    if (isForgotPassword.value) {
      verifyForResetPassword(); // Lari ke fungsi Lupa Password
    } else {
      verifyAndRegister(); // Lari ke fungsi Registrasi
    }
  }

  // --- LOGIKA REGISTRASI (Tidak diubah, tetap sesuai kode asli Anda) ---
  Future<void> verifyAndRegister() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      Get.snackbar("Error", "Kode OTP tidak boleh kosong",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await authService.registerManual(
          name.value, email.value, password.value, otp);

      print("STATUS CODE SERVER: ${response.statusCode}");
      print("BODY SERVER: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Sukses", "Akun berhasil dibuat, silakan login",
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAllNamed('/login');
      } else {
        var data = response.body;
        String errorMsg = "Verifikasi OTP Gagal";
        if (data != null) {
          try {
            if (data is String) data = jsonDecode(data);
          } catch (_) {}
          if (data is Map) {
            errorMsg = data['detail']?.toString() ?? errorMsg;
          }
        }
        Get.snackbar("Gagal", errorMsg,
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print("ERROR: $e");
      Get.snackbar("Error Jaringan", "Terjadi kesalahan saat memverifikasi OTP",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // 🟢 LOGIKA BARU: Verifikasi OTP untuk Forgot Password
  Future<void> verifyForResetPassword() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      Get.snackbar("Error", "Kode OTP tidak boleh kosong",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      // TODO: Ganti blok simulasi ini dengan pemanggilan API ke AuthService Anda nanti
      // Contoh pemanggilan API asli:
      // final response = await authService.verifyForgotPasswordOtp(email.value, otp);

      // --- SIMULASI SEMENTARA ---
      await Future.delayed(const Duration(seconds: 2));

      // Kita anggap kode "1234" adalah OTP yang benar untuk simulasi
      if (otp == "1234") {
        // Jika benar, pindah ke halaman pembuatan password baru
        Get.offNamed('/reset-password', arguments: {'email': email.value});
      } else {
        Get.snackbar("Gagal", "Kode OTP salah atau telah kedaluwarsa",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
      // --- BATAS SIMULASI ---
    } catch (e) {
      print("ERROR: $e");
      Get.snackbar("Error Jaringan", "Terjadi kesalahan saat memverifikasi OTP",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
