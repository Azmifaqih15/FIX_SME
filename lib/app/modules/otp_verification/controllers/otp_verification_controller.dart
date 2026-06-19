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
    }
  }

  Future<void> verifyAndRegister() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      Get.snackbar("Error", "Kode OTP tidak boleh kosong", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await authService.registerManual(name.value, email.value, password.value, otp);
      
      print("STATUS CODE SERVER: ${response.statusCode}");
      print("BODY SERVER: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Sukses",
          "Akun berhasil dibuat, silakan login",
          backgroundColor: Colors.green,
          colorText: Colors.white
        );
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
        Get.snackbar("Gagal", errorMsg, backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print("ERROR: $e");
      Get.snackbar("Error Jaringan", "Terjadi kesalahan saat memverifikasi OTP", backgroundColor: Colors.red, colorText: Colors.white);
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
