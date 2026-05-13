import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A1F44); // Biru tua sesuai gambar
    const Color inputFieldColor = Color(0xFFF1F1F1); // Abu-abu terang

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Smart-SME',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: false, // Posisi di kiri seperti gambar
        actions: [
          const Text('Registration', style: TextStyle(color: Colors.grey, fontSize: 12)),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // 📦 Card Container
              Card(
                elevation: 5,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Register now',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Bergabunglah dengan ribuan pemilik UMKM yang menggunakan infrastruktur cerdas kami untuk mengembangkan visi mereka.',
                        style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
                      ),
                      const SizedBox(height: 32),

                      // 1. FULL NAME
                      _buildLabel('FULL NAME'),
                      _buildTextField(controller.nameController, 'John Doe', inputFieldColor),
                      const SizedBox(height: 20),

                      // 2. WORK EMAIL
                      _buildLabel('WORK EMAIL'),
                      _buildTextField(controller.emailController, 'john@business.com', inputFieldColor),
                      const SizedBox(height: 20),

                      // 3. PASSWORD
                      _buildLabel('PASSWORD'),
                      Obx(() => Container(
                        decoration: BoxDecoration(
                          color: inputFieldColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: controller.passwordController,
                          obscureText: !controller.isPasswordVisible.value,
                          decoration: InputDecoration(
                            hintText: '••••••••••••',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: controller.togglePassword,
                            ),
                          ),
                        ),
                      )),
                      const SizedBox(height: 20),

                      // Checkbox Terms
                      Obx(() => Row(
                        children: [
                          Checkbox(
                            value: controller.isAgree.value,
                            onChanged: (val) => controller.toggleAgree(val),
                            activeColor: primaryColor,
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                    recognizer: TapGestureRecognizer()..onTap = () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                      const SizedBox(height: 32),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Continue Registration',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                        )),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Get.back(),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black54),
                    children: [
                      TextSpan(text: 'Sudah punya akun? '),
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }

  // Widget Helper untuk TextField Abu-abu
  Widget _buildTextField(TextEditingController ctrl, String hint, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}