import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:smart_sme_app/app/data/api_config.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();

  // Variabel untuk memunculkan efek loading saat tombol ditekan
  var isLoading = false.obs;

  // GANTI IP INI DENGAN IP LOKAL LAPTOP ANDA JIKA MENGGUNAKAN HP FISIK (Cek via cmd: ipconfig)
  // Contoh: 'http://192.168.1.10:8000'
  final String baseUrl = ApiConfig.BASE_URL;

  void sendOtp() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;

      try {
        final fullUrl = '$baseUrl/auth/forgot-password';
        ApiConfig.logNetwork(fullUrl);
        print('Data body yang dikirim: {"email": "${emailCtrl.text.trim()}"}');
        
        final response = await http.post(
          Uri.parse(fullUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': emailCtrl.text.trim()}),
        ).timeout(const Duration(seconds: 15)); // Timeout 15 detik

        if (response.statusCode == 200) {
          Get.snackbar(
            "OTP Sent",
            "Silakan periksa kotak masuk email Anda.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
          Get.toNamed('/otp-verification', arguments: {'email': emailCtrl.text.trim(), 'isForgotPassword': true});
        } else {
          final responseData = jsonDecode(response.body);
          Get.snackbar(
            "Gagal",
            responseData['detail'] ?? "Terjadi kesalahan",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } on SocketException catch (e) {
        Get.snackbar(
          "Socket Exception",
          "Gagal terhubung ke server: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } on TimeoutException catch (e) {
        Get.snackbar(
          "Timeout Exception",
          "Koneksi terlalu lama (Timeout): $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } catch (e) {
        print('ERROR FATAL JARINGAN: ${e.toString()}');
        Get.snackbar(
          "Error",
          "Koneksi ke server gagal: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }
}
