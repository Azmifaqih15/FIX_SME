import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_sme_app/app/data/services/auth_service.dart';

class OtpController extends GetxController {
  final box = GetStorage();
  late AuthService authService;

  var email = ''.obs;
  var name = ''.obs;
  var password = ''.obs;
  var isRegistration = false.obs;

  var isLoading = false.obs;
  final otpController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    try {
      authService = Get.find<AuthService>();
    } catch (e) {
      authService = Get.put(AuthService());
    }

    if (Get.arguments != null) {
      if (Get.arguments is Map) {
        final Map args = Get.arguments as Map;
        email.value = args['email'] ?? '';
        name.value = args['name'] ?? '';
        password.value = args['password'] ?? '';
        isRegistration.value = args['is_registration'] ?? false;
      } else {
        email.value = Get.arguments.toString();
      }
    }
  }

  /// Memanggil endpoint API berdasarkan asal form OTP (Registrasi atau lainnya)
  Future<void> verifyOTP() async {
    final code = otpController.text.trim();
    if (code.isEmpty) {
      Get.snackbar("Peringatan", "Kode OTP tidak boleh kosong!", backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return;
    }

    if (code.length < 4 || code.length > 6) {
      Get.snackbar("Peringatan", "Kode OTP harus berjumlah 4-6 digit!", backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      Response response;

      if (isRegistration.value) {
        // [ALUR REGISTRASI BARU]
        print("Memverifikasi OTP untuk Registrasi Akun...");
        response = await authService.registerManual(name.value, email.value, password.value, code);
      } else {
        // [ALUR OTP BIASA - Cth: Forgot Password]
        print("Memverifikasi OTP Biasa...");
        response = await authService.verifyOTP(email.value, code);
      }

      print("Verify OTP Status: ${response.statusCode}");
      print("Verify OTP Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Sukses", isRegistration.value ? "Registrasi berhasil!" : "Verifikasi OTP berhasil!", backgroundColor: Colors.green, colorText: Colors.white);
        
        // Arahkan ke Dashboard
        Get.offAllNamed('/dashboard');
      } else {
        var data = response.body;
        String errorDetail = "Kode OTP salah atau telah kedaluwarsa";
        
        if (data != null) {
          try {
            if (data is String) data = jsonDecode(data);
          } catch (_) {}
          
          if (data is Map) {
            var detail = data['detail'];
            if (detail is String) {
              errorDetail = detail;
            } else if (detail is List) {
              errorDetail = detail.map((e) {
                if (e is Map) return e['msg'] ?? e.toString();
                return e.toString();
              }).join(", ");
            }
          }
        }

        Get.snackbar("Gagal", errorDetail, backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print("Verify OTP Error: $e");
      Get.snackbar("Error Jaringan", "Gagal menghubungi backend untuk verifikasi", backgroundColor: Colors.red, colorText: Colors.white);
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
