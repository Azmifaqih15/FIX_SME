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
        centerTitle: false,
        actions: [
          const Center(
            child: Text('Registration', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: '••••••••••••',
                                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Checkbox(
                                          value: controller.isAgree.value,
                                          onChanged: (val) => controller.toggleAgree(val),
                                          activeColor: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
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
                                      ),
                                    ],
                                  )),
                                  const SizedBox(height: 32),

                                  // Tombol Utama (Continue Registration)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: Obx(() => ElevatedButton(
                                      onPressed: controller.isLoading.value ? null : () => controller.registerUser(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        disabledBackgroundColor: Colors.grey.shade300,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: controller.isLoading.value
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                            )
                                          : const Text(
                                              'Continue Registration',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
                                style: TextStyle(color: Colors.black54, fontSize: 14),
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
                ),
              ),
            );
          },
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

  // Widget Helper untuk TextField Abu-abu (Dioptimalkan)
  Widget _buildTextField(TextEditingController ctrl, String hint, Color color, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.black87, fontSize: 14), // 🔥 Memastikan teks input terlihat jelas
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