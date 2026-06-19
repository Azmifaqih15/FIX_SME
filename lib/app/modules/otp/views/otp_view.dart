import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF111827)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ICON/HEADER ---
              const Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFFF3F4F6),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 40,
                    color: Color(0xFF111E38),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- TITLE & SUBTITLE ---
              const Text(
                "Verifikasi Kode OTP",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                  children: [
                    const TextSpan(text: "Kami telah mengirimkan kode verifikasi 4-6 digit ke email Anda: "),
                    TextSpan(
                      text: controller.email.value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const TextSpan(text: ". Silakan masukkan kode tersebut di bawah ini untuk melanjutkan."),
                  ],
                ),
              )),
              const SizedBox(height: 40),

              // --- TEXTFIELD OTP ---
              const Text(
                "Kode OTP",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8.0,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  hintText: "••••••",
                  hintStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8.0,
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.security),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- TOMBOL VERIFIKASI ---
              Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111E38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.verifyOTP(),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Verifikasi",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )),
              const SizedBox(height: 24),

              // --- RESEND FOOTER ---
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Tidak menerima kode?",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.snackbar(
                          "Info", 
                          "Silakan kembali ke halaman Login dan klik tombol Google Sign-In lagi untuk mengirim ulang kode OTP.",
                          backgroundColor: const Color(0xFF111E38),
                          colorText: Colors.white
                        );
                      },
                      child: const Text(
                        "Kirim Ulang",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111E38),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
