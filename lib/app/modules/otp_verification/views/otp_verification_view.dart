import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/otp_verification_controller.dart';

class OtpVerificationView extends GetView<OtpVerificationController> {
  const OtpVerificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Email'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Masukkan Kode OTP",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Obx(() => Text(
                  "Kode OTP telah dikirimkan ke email:\n${controller.email.value}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                )),
            const SizedBox(height: 30),
            Obx(() => TextField(
                  controller: controller.otpController,
                  keyboardType: TextInputType.number,
                  maxLength: controller.isForgotPassword.value ? 6 : 4, // 6 untuk Lupa Password, 4 untuk Registrasi
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 10),
                  decoration: InputDecoration(
                    hintText: controller.isForgotPassword.value ? "000000" : "0000",
                    border: const OutlineInputBorder(),
                    counterText: "",
                  ),
                )),
            const SizedBox(height: 30),
            Obx(() => ElevatedButton(
                  // 🟢 Panggil fungsi utama yang menangani logika cabang
                  onPressed:
                      controller.isLoading.value ? null : controller.submitOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      // 🟢 Teks tombol berubah secara dinamis
                      : Text(
                          controller.isForgotPassword.value
                              ? "Verifikasi & Lanjut"
                              : "Verifikasi & Daftar",
                          style: const TextStyle(fontSize: 18)),
                )),
          ],
        ),
      ),
    );
  }
}
