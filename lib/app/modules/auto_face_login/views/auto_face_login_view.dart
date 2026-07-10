import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controllers/auto_face_login_controller.dart';

class AutoFaceLoginView extends GetView<AutoFaceLoginController> {
  const AutoFaceLoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Tampilan Kamera (Full Screen)
          Obx(() {
            if (controller.isCameraInitialized.value && controller.cameraController != null) {
              return CameraPreview(controller.cameraController!);
            } else {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
          }),

          // 2. UI Overlay (Petunjuk & Hitung Mundur)
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header (Tombol Back)
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),

                // Petunjuk & Hitung Mundur
                Obx(() {
                  if (controller.isLoading.value) {
                    return const SizedBox.shrink(); // Sembunyikan teks saat loading
                  }
                  return Column(
                    children: [
                      const Text(
                        'Posisikan wajah Anda\ndi dalam layar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Memotret dalam ${controller.countdown.value}...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 40), // Spacing bawah
              ],
            ),
          ),

          // 3. Loading Overlay saat mengirim foto ke server
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.blueAccent),
                      SizedBox(height: 20),
                      Text(
                        'Memverifikasi Wajah...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }
}
