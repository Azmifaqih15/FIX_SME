import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_sme_app/app/data/api_config.dart';
import 'package:smart_sme_app/app/data/services/auth_service.dart';

class AutoFaceLoginController extends GetxController {
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  var isCameraInitialized = false.obs;
  var isCapturing = false.obs;

  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();
      // Cari kamera depan
      final frontCamera = cameras?.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras!.first,
      );

      if (frontCamera != null) {
        cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await cameraController!.initialize();
        isCameraInitialized.value = true;

        // Auto-capture logic: 2 detik
        Future.delayed(const Duration(seconds: 2), () {
          if (!isCapturing.value && cameraController != null) {
            autoCapture();
          }
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menginisialisasi kamera: $e");
    }
  }

  Future<void> autoCapture() async {
    if (cameraController == null || !cameraController!.value.isInitialized) return;

    try {
      isCapturing.value = true;
      final XFile image = await cameraController!.takePicture();
      
      // Update UI untuk berhenti menampilkan preview kamera sebelum di-dispose
      isCameraInitialized.value = false;
      
      // Hentikan kamera
      if (cameraController != null) {
        await cameraController!.dispose();
        cameraController = null;
      }

      // Munculkan loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await sendToBackend(image.path);
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil gambar: $e");
    }
  }

  Future<void> sendToBackend(String imagePath) async {
    try {
      String baseUrl = ApiConfig.BASE_URL;
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/face'));

      request.headers.addAll({
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      });

      var file = await http.MultipartFile.fromPath('file', imagePath);
      request.files.add(file);

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
        onTimeout: () {
          throw "Request Timeout: Proses memakan waktu terlalu lama (Model AI mungkin sedang diunduh).";
        },
      );
      var responseData = await http.Response.fromStream(streamedResponse);
      
      // Tutup loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (responseData.statusCode == 200 || responseData.statusCode == 201) {
        var data = jsonDecode(responseData.body);
        String token = data['access_token'] ?? "";
        String name = data['data'] != null ? data['data']['name'] : "User";
        String userEmail = data['data'] != null && data['data']['email'] != null ? data['data']['email'] : "";
        String photoUrl = data['data'] != null && data['data']['photo_url'] != null ? data['data']['photo_url'] : "";
        
        var userIdRaw = data['data'] != null ? data['data']['id'] : null;
        String userIdStr = userIdRaw != null ? userIdRaw.toString() : "";

        final box = GetStorage();
        await box.write('isLogin', true);
        await box.write('is_google_login', false);
        await box.write('user_name', name);
        await box.write('email', userEmail);
        await box.write('user_photo', photoUrl);
        
        if (userIdStr.isNotEmpty) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userIdStr);
        }

        if (token.isNotEmpty) {
           final authService = Get.find<AuthService>();
           authService.saveToken(token);
        }

        Get.snackbar("Sukses", "Login Face ID Berhasil! Selamat datang, $name", backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAllNamed('/dashboard');
      } else {
        // Gagal, kembali ke halaman login (hapus view ini dari stack)
        Get.back();
        
        String errorDetail = "Wajah tidak cocok atau tidak terdeteksi";
        try {
          var data = jsonDecode(responseData.body);
          if (data['detail'] != null) errorDetail = data['detail'].toString();
        } catch (_) {}
        Get.snackbar("Gagal", errorDetail, backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.back(); // Kembali ke halaman login
      Get.snackbar("Error", "Terjadi kesalahan pada sistem Face ID: $e", backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
