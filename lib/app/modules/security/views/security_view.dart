import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/security_controller.dart';

class SecurityView extends GetView<SecurityController> {
  const SecurityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Security",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: LOGIN OPTIONS ---
            const Text(
              "Login Options",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111E38)),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Obx(() => SwitchListTile(
                        title: const Text("Face ID / Biometric",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text(
                            "Login instantly using your biometrics",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              shape: BoxShape.circle),
                          child: const Icon(
                              Icons.face_retouching_natural_rounded,
                              color: Colors.purple),
                        ),
                        value: controller.isFaceIdEnabled.value,
                        activeColor: const Color(0xFF4F46E5),
                        onChanged: controller.toggleFaceId,
                      )),
                  const Divider(height: 1, indent: 64),
                  Obx(() => SwitchListTile(
                        title: const Text("Two-Step Verification",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text(
                            "Require an extra code during login",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.phonelink_lock_rounded,
                              color: Colors.green),
                        ),
                        value: controller.isTwoFactorEnabled.value,
                        activeColor: const Color(0xFF4F46E5),
                        onChanged: controller.toggleTwoFactor,
                      )),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- SECTION 2: CHANGE PASSWORD ---
            const Text(
              "Change Password",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111E38)),
            ),
            const SizedBox(height: 16),
            Form(
              key: controller.formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildPasswordField(
                      controller: controller.currentPwdCtrl,
                      label: "Current Password",
                      obsVar: controller.obsCurrent,
                      validator: (v) =>
                          v!.isEmpty ? 'Enter current password' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: controller.newPwdCtrl,
                      label: "New Password",
                      obsVar: controller.obsNew,
                      validator: (v) {
                        if (v!.isEmpty) return 'Enter new password';
                        if (v.length < 6)
                          return 'Password too short (min. 6 chars)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: controller.confirmPwdCtrl,
                      label: "Confirm New Password",
                      obsVar: controller.obsConfirm,
                      validator: (v) {
                        if (v!.isEmpty) return 'Confirm your new password';
                        if (v != controller.newPwdCtrl.text)
                          return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111E38),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text("Update Password",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk Text Field Password
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required RxBool obsVar,
    required String? Function(String?) validator,
  }) {
    return Obx(() => TextFormField(
          controller: controller,
          obscureText: obsVar.value,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                color: Color(0xFF64748B), size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obsVar.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () => obsVar.value = !obsVar.value,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          validator: validator,
        ));
  }
}
