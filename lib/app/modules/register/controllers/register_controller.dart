import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:smart_sme_app/app/data/api_config.dart';
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

  // 🟢 State untuk Foto (BARU)
  var selectedImagePath = ''.obs;

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

  // 🟢 Fungsi untuk membuka kamera depan dan mengambil foto wajah
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 50,
    );

    if (image != null) {
      selectedImagePath.value = image.path;
    }
  }

  void requestOTP() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar("Error", "Email harus diisi untuk mengirim OTP",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isSendingOtp.value = true;
    try {
      final response = await authService.sendOtpRequest(email);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Sukses", "Kode OTP telah dikirim ke email Anda",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        var data = response.body;
        String errorMsg = "Gagal mengirim OTP";
        if (data is Map && data['detail'] != null) {
          errorMsg = data['detail'].toString();
        } else if (data is Map && data['message'] != null) {
          errorMsg = data['message'].toString();
        }
        Get.snackbar("Gagal", errorMsg,
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menghubungi server: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSendingOtp.value = false;
    }
  }

  void registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Nama, Email, dan Password harus diisi",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (!isAgree.value) {
      Get.snackbar("Error", "Anda harus menyetujui Terms of Service",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // Jika Foto Profil terisi, gunakan alur Face Register
    if (selectedImagePath.value.isNotEmpty) {
      isLoading.value = true;
      try {
        // Minta OTP ke email terlebih dahulu
        final response = await authService.sendOtpRequest(email);

        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar("Sukses", "Kode OTP telah dikirim ke email Anda",
              backgroundColor: Colors.green, colorText: Colors.white);

          // Tampilkan Pop-Up OTP
          _showOtpDialog(name, email, password);
        } else {
          var data = response.body;
          String errorMsg = "Gagal mengirim OTP";

          if (data != null) {
            try {
              if (data is String) data = jsonDecode(data);
            } catch (_) {}

            if (data is Map) {
              errorMsg = data['detail']?.toString() ??
                  data['message']?.toString() ??
                  errorMsg;
            }
          }

          Get.snackbar("Gagal", errorMsg,
              backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      } catch (e) {
        Get.snackbar(
            "Error", "Terjadi kesalahan: $e",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      } finally {
        isLoading.value = false;
      }
      return; // Berhenti di sini karena ini alur Face Register
    }

    // ALUR MANUAL (Jika foto profil kosong)
    isLoading.value = true;
    try {
      // 1. Minta OTP ke email terlebih dahulu
      final response = await authService.sendOtpRequest(email);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Sukses", "Kode OTP telah dikirim ke email Anda",
            backgroundColor: Colors.green, colorText: Colors.white);

        // 2. Pindah ke halaman OTP dengan membawa data yang sudah diisi
        Get.toNamed('/otp', arguments: {
          'name': name,
          'email': email,
          'password': password,
          'imagePath': selectedImagePath.value,
          'is_registration': true
        });
      } else {
        var data = response.body;
        String errorMsg = "Gagal mengirim OTP";

        if (data != null) {
          try {
            if (data is String) data = jsonDecode(data);
          } catch (_) {}

          if (data is Map) {
            errorMsg = data['detail']?.toString() ??
                data['message']?.toString() ??
                errorMsg;
          }
        }

        Get.snackbar("Gagal", errorMsg,
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar(
          "Error Jaringan", "Tidak dapat terhubung ke server backend: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _showOtpDialog(String name, String email, String password) {
    otpController.clear();
    Get.defaultDialog(
      title: "Verifikasi OTP",
      content: Column(
        children: [
          const Text("Masukkan 6-digit OTP yang dikirim ke email Anda"),
          const SizedBox(height: 16),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              hintText: "Contoh: 123456",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          if (otpController.text.length == 6) {
            Get.back(); // Tutup dialog
            _submitFaceRegisterWithOtp(name, email, password, otpController.text);
          } else {
            Get.snackbar("Error", "Masukkan 6 digit OTP",
                backgroundColor: Colors.redAccent, colorText: Colors.white);
          }
        },
        child: const Text("Verifikasi"),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Batal"),
      ),
    );
  }

  void _submitFaceRegisterWithOtp(String name, String email, String password, String otp) async {
    isLoading.value = true;
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    
    try {
      String baseUrl = ApiConfig.BASE_URL;
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/face-register'));
      
      request.headers.addAll({
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      });
      
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['otp'] = otp;
      
      request.files.add(await http.MultipartFile.fromPath('file', selectedImagePath.value));
      
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw "Request Timeout: Proses memakan waktu terlalu lama.";
        },
      );
      
      var responseData = await http.Response.fromStream(streamedResponse);
      
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      if (responseData.statusCode == 200 || responseData.statusCode == 201) {
        Get.snackbar("Pendaftaran Berhasil", "Registrasi wajah sukses, silahkan login.",
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAllNamed('/login');
      } else {
        String errorMsg = "Wajah tidak terdeteksi atau pendaftaran gagal";
        try {
          var data = jsonDecode(responseData.body);
          if (data['detail'] != null) errorMsg = data['detail'].toString();
        } catch (_) {}
        
        Get.snackbar("Gagal", errorMsg,
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar("Error", "Terjadi kesalahan pada jaringan: $e",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
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
