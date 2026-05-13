import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_sme_app/app/data/providers/auth_provider.dart';

class RegisterController extends GetxController {
  final authProvider = AuthProvider();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Loading
  var isLoading = false.obs;

  // Show / Hide Password
  var isPasswordVisible = false.obs;

  // Checkbox Terms
  var isAgree = false.obs;

  // Toggle password visibility
  void togglePassword() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Toggle checkbox
  void toggleAgree(bool? value) {
    isAgree.value = value ?? false;
  }

  void register() async {

    // Validasi field
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar("Error", "Semua field harus diisi");
      return;
    }

    // Validasi checkbox
    if (!isAgree.value) {
      Get.snackbar("Error", "Anda harus menyetujui Terms of Service");
      return;
    }

    isLoading.value = true;

    try {
      final response = await authProvider.register(
        nameController.text,
        emailController.text,
        passwordController.text,
      );

      if (response.statusCode == 201 ||
          response.statusCode == 200) {

        Get.snackbar(
          "Sukses",
          "Akun berhasil dibuat, silakan login",
        );

        Get.offNamed('/login');

      } else {

        Get.snackbar(
          "Gagal",
          response.body['message'] ?? "Terjadi kesalahan",
        );
      }

    } catch (e) {

      Get.snackbar(
        "Error",
        e.toString(),
      );

    } finally {

      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}