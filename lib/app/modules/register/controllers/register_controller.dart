import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// Pastikan path import AuthService ini sesuai dengan letak folder kamu
import 'package:smart_sme_app/app/data/services/auth_service.dart';

class RegisterController extends GetxController {
  final box = GetStorage();
  late AuthService authService; 

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  // Loading State
  var isLoading = false.obs;
  var isSendingOtp = false.obs;

  // Show / Hide Password
  var isPasswordVisible = false.obs;

  // Checkbox Terms
  var isAgree = false.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      authService = Get.find<AuthService>();
    } catch (e) {
      authService = Get.put(AuthService());
    }
  }

  // Toggle password visibility
  void togglePassword() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Toggle checkbox
  void toggleAgree(bool? value) {
    isAgree.value = value ?? false;
  }

  void requestOTP() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar("Error", "Email harus diisi untuk mengirim OTP", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isSendingOtp.value = true;
    try {
      final response = await authService.sendOtpRequest(email);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Sukses", "Kode OTP telah dikirim ke email Anda", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        var data = response.body;
        String errorMsg = "Gagal mengirim OTP";
        if (data is Map && data['detail'] != null) {
          errorMsg = data['detail'].toString();
        } else if (data is Map && data['message'] != null) {
          errorMsg = data['message'].toString();
        }
        Get.snackbar("Gagal", errorMsg, backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menghubungi server: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSendingOtp.value = false;
    }
  }

  void registerUser() async {
    final name = nameController.text.trim(); 
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Semua field harus diisi", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (!isAgree.value) {
      Get.snackbar("Error", "Anda harus menyetujui Terms of Service", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      // 1. Minta OTP ke email terlebih dahulu
      final response = await authService.sendOtpRequest(email);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Sukses", "Kode OTP telah dikirim ke email Anda", backgroundColor: Colors.green, colorText: Colors.white);
        
        // 2. Pindah ke halaman OTP dengan membawa data yang sudah diisi
        Get.toNamed('/otp', arguments: {
          'name': name,
          'email': email,
          'password': password,
          'is_registration': true
        });
      } else {
        print("DEBUG FRONTEND OTP ERROR: ${response.body}");
        var data = response.body;
        String errorMsg = "Gagal mengirim OTP";
        
        if (data != null) {
          try {
            if (data is String) data = jsonDecode(data);
          } catch (_) {}
          
          if (data is Map) {
            errorMsg = data['detail']?.toString() ?? data['message']?.toString() ?? errorMsg;
          }
        }
        
        Get.snackbar("Gagal", errorMsg, backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      print("ERROR CRASH: $e");
      Get.snackbar("Error Jaringan", "Tidak dapat terhubung ke server backend: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.onClose();
  }
}