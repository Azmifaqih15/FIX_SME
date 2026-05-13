import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
// Pastikan path import ini sesuai dengan lokasi file AuthService Anda
import 'package:smart_sme_app/app/data/services/auth_service.dart'; 

class LoginController extends GetxController {
  final box = GetStorage();

  // Gunakan Get.put jika AuthService belum diinisialisasi di Binding
  // Atau tetap Get.find jika sudah di-put di InitialBinding/LoginBinding
  late AuthService authService;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi authService saat controller dibuat
    try {
      authService = Get.find<AuthService>();
    } catch (e) {
      // Fallback jika lupa menaruh di binding
      authService = Get.put(AuthService());
    }
  }

  // --- State ---
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  void togglePassword() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// LOGIN MANUAL (Simulasi sesuai kode Anda)
  Future<void> login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar("Error", "Email & Password wajib diisi");
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); 

    final savedEmail = box.read('email');
    final savedPassword = box.read('password');

    if (email.value == savedEmail && password.value == savedPassword) {
      box.write('isLogin', true);
      Get.snackbar("Success", "Login berhasil");
      Get.offAllNamed('/home');
    } else {
      Get.snackbar("Error", "Email atau Password salah");
    }
    isLoading.value = false;
  }

  /// LOGIN BIOMETRIC (Face ID)
  Future<void> loginWithFaceID() async {
    bool success;
    if (kIsWeb) {
      success = true; 
    } else {
      success = await authService.authenticate();
    }

    if (success) {
      box.write('isLogin', true);
      Get.snackbar("Success", "Login dengan Face ID berhasil");
      Get.offAllNamed('/dashboard');
    } else {
      // Notifikasi gagal sesuai standar Penjamin Mutu [cite: 46, 47]
      Get.snackbar("Error", "Gagal autentikasi biometrik");
    }
  }
}