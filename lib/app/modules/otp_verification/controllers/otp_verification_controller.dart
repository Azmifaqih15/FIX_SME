import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_sme_app/app/data/services/auth_service.dart';

class OtpVerificationController extends GetxController {
  late AuthService authService;

  var name = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var imagePath = ''.obs;
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
      imagePath.value = Get.arguments['imagePath'] ?? '';

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
          name.value, email.value, password.value, otp, imagePath: imagePath.value);

      print("=== RESPONSE DARI BACKEND ===");
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Ekstrak data JSON dari response backend
        var data = response.body;
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (_) {}
        }
        
        String registeredName = "User";
        String photoUrl = "";
        if (data is Map && data['data'] != null) {
          if (data['data']['name'] != null) registeredName = data['data']['name'];
          if (data['data']['photo_url'] != null) photoUrl = data['data']['photo_url'];
        }

        print("Menyimpan ke memori -> Nama: $registeredName, Foto: $photoUrl");

        // Simpan name ke local storage
        final box = GetStorage();
        await box.write('user_name', registeredName);
        await box.write('user_photo', photoUrl);

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
    if (otp.length != 6) {
      Get.snackbar("Error", "Masukkan 6 digit OTP",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await authService.verifyResetOtp(email.value, otp);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Langsung arahkan ke halaman reset password sambil membawa email dan otp
        // Karena endpoint Supabase reset-password membutuhkan otp dan new_password
        Get.offNamed('/reset-password', arguments: {
          'email': email.value,
          'otp': otp,
        });
      } else {
        var data = response.body;
        String errorMsg = "Kode OTP salah atau sudah kedaluwarsa";
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

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
