import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:smart_sme_app/app/data/api_config.dart';

class ResetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // State untuk menyembunyikan/menampilkan isi teks password (ikon mata)
  var isObscureNew = true.obs;
  var isObscureConfirm = true.obs;

  var isLoading = false.obs;
  var userEmail = ''.obs;
  var userOtp = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Menangkap email dan otp yang dikirim dari halaman verifikasi OTP sebelumnya
    if (Get.arguments != null) {
      userEmail.value = Get.arguments['email'] ?? '';
      userOtp.value = Get.arguments['otp'] ?? '';
    }
  }

  bool _isPasswordStrong(String password) {
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(password);
  }

  // GANTI IP INI DENGAN IP LOKAL LAPTOP ANDA JIKA MENGGUNAKAN HP FISIK
  final String baseUrl = ApiConfig.BASE_URL;

  Future<void> submitResetPassword() async {
    if (formKey.currentState!.validate()) {
      if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
        Get.snackbar("Error", "Password tidak cocok!", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      if (!_isPasswordStrong(newPasswordCtrl.text)) {
        Get.snackbar(
          "Password Lemah",
          "Password minimal 8 karakter, huruf besar, angka, dan simbol.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Validasi lokal: Pastikan OTP 6 digit
      if (userOtp.value.length != 6) {
        Get.snackbar(
          "Error",
          "Masukkan 6 digit OTP",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      try {
        final fullUrl = '$baseUrl/auth/reset-password';
        ApiConfig.logNetwork(fullUrl);
        final response = await http.post(
          Uri.parse(fullUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': userEmail.value,
            'otp_code': userOtp.value,
            'new_password': newPasswordCtrl.text,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          Get.snackbar(
            "Sukses",
            "Password berhasil diubah!",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
          );

          // Menghapus semua riwayat halaman dan kembali ke Login
          Get.offAllNamed('/login');
        } else {
          Get.snackbar(
            "Gagal Mereset Password",
            responseData['detail'] ?? "OTP salah atau kedaluwarsa.",
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      } on SocketException catch (_) {
        Get.snackbar(
          "Error",
          "Gagal terhubung ke server. Pastikan aplikasi dan server berada di jaringan yang sama.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } on TimeoutException catch (_) {
        Get.snackbar(
          "Error",
          "Gagal terhubung ke server. Pastikan aplikasi dan server berada di jaringan yang sama.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } catch (e) {
        Get.snackbar(
          "Error Jaringan",
          "Terjadi kesalahan saat menyimpan password baru: $e",
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
