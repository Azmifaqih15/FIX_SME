import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:smart_sme_app/app/data/api_config.dart';

class AutoFaceLoginController extends GetxController {
  CameraController? cameraController;
  late List<CameraDescription> _cameras;
  var isCameraInitialized = false.obs;
  var isLoading = false.obs;
  var countdown = 2.obs; // Hitung mundur 2 detik

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      // Cari kamera depan (front)
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first, // Fallback ke kamera pertama jika tidak ada kamera depan
      );

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
      
      // Mulai proses hitung mundur otomatis
      _startAutoCapture();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menginisialisasi kamera: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      Get.back();
    }
  }

  void _startAutoCapture() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 1) {
        countdown.value--;
      } else {
        timer.cancel();
        _takeAndSendPicture();
      }
    });
  }

  Future<void> _takeAndSendPicture() async {
    if (!cameraController!.value.isInitialized) return;

    try {
      isLoading.value = true;
      
      // Ambil foto
      final XFile picture = await cameraController!.takePicture();
      
      // Kirim ke backend
      await _sendFaceLoginRequest(picture.path);
      
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Gagal mengambil foto: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      Get.offAllNamed('/login'); // Kembali ke login jika gagal
    }
  }

  Future<void> _sendFaceLoginRequest(String imagePath) async {
    try {
      String baseUrl = ApiConfig.BASE_URL;
      var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}auth/face'));

      request.headers.addAll({
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      });

      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw "Request Timeout: Proses memakan waktu terlalu lama.";
        },
      );

      var response = await http.Response.fromStream(streamedResponse);
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Login Wajah Berhasil!',
            backgroundColor: Colors.green, colorText: Colors.white);
        
        // Simpan token (bisa gunakan GetStorage / SharedPreferences sesuai preferensi Anda)
        // misalnya: box.write('token', responseData['access_token']);
        
        Get.offAllNamed('/dashboard');
      } else if (response.statusCode == 401) {
        Get.snackbar('Gagal', 'Wajah tidak dikenali atau tidak terdaftar.',
            backgroundColor: Colors.red, colorText: Colors.white);
        Get.offAllNamed('/login'); // Kembali ke login jika wajah salah
      } else {
        Get.snackbar('Error', responseData['detail'] ?? 'Terjadi kesalahan.',
            backgroundColor: Colors.red, colorText: Colors.white);
        Get.offAllNamed('/login');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal terhubung ke server: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
