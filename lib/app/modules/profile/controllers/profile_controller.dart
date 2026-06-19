import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart'; // 🟢 DITAMBAHKAN: Import Image Picker
import '../../../routes/app_pages.dart';
import 'dart:io';

class ProfileController extends GetxController {
  final box = GetStorage();
  final ImagePicker _picker = ImagePicker();

  var name = "John Doe".obs;
  var email = "john@business.com".obs;
  var activityLogs = <Map<String, dynamic>>[].obs;
  var profileImagePath = ''.obs;
  var editingProfileImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      if (Get.arguments['name'] != null) {
        name.value = Get.arguments['name'];
      }
      if (Get.arguments['email'] != null) {
        email.value = Get.arguments['email'];
      }
    }

    final storedName = box.read('name');
    final storedEmail = box.read('email');
    // 🟢 DITAMBAHKAN: Membaca gambar profil yang tersimpan
    final storedImagePath = box.read('profile_image_path');

    if (storedName != null && storedName is String && storedName.isNotEmpty) {
      name.value = storedName;
    }
    if (storedEmail != null &&
        storedEmail is String &&
        storedEmail.isNotEmpty) {
      email.value = storedEmail;
    }
    // 🟢 DITAMBAHKAN: Memuat path gambar profil
    if (storedImagePath != null && storedImagePath is String) {
      profileImagePath.value = storedImagePath;
    }

    _loadActivityLogs();
  }

  // 🟢 DITAMBAHKAN: Fungsi untuk mengambil gambar dari galeri
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        editingProfileImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil gambar: $e");
    }
  }

  void _loadActivityLogs() {
    activityLogs.value = [
      {
        "title": "Added new product 'Basic White Tee'",
        "time": "Today, 10:30 AM",
        "icon": Icons.add_box_rounded,
        "color": Colors.green,
      },
      {
        "title": "Generated PO for 'Lavender Soap'",
        "time": "Yesterday, 15:45 PM",
        "icon": Icons.sync_rounded,
        "color": Colors.blue,
      },
      {
        "title": "Updated stock 'Oversize Hoodie'",
        "time": "Mon, 09:15 AM",
        "icon": Icons.inventory_2_rounded,
        "color": Colors.orange,
      },
      {
        "title": "Logged in via Face ID",
        "time": "Mon, 08:00 AM",
        "icon": Icons.face_retouching_natural_rounded,
        "color": Colors.purple,
      },
    ];
  }

  void editProfile() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: name.value);
    final emailCtrl = TextEditingController(text: email.value);

    // 🟢 DITAMBAHKAN: Menyamakan gambar sementara dengan gambar yang sedang dipakai sebelum diedit
    editingProfileImagePath.value = profileImagePath.value;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111E38),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Update your personal information below.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // 🟢 DITAMBAHKAN: Antarmuka Upload Foto Profil
                  Center(
                    child: GestureDetector(
                      onTap: pickProfileImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFEEF2FF),
                            ),
                            child: Obx(() {
                              final path = editingProfileImagePath.value;
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: path.isEmpty
                                    ? Container(
                                        width: 100,
                                        height: 100,
                                        color: const Color(0xFFC7D2FE),
                                        child: const Icon(Icons.person,
                                            size: 50, color: Color(0xFF4F46E5)),
                                      )
                                    : Image.file(
                                        File(path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                              );
                            }),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4F46E5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return 'Email is required';
                      if (!s.contains('@')) return 'Invalid email format';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        name.value = nameCtrl.text.trim();
                        email.value = emailCtrl.text.trim();

                        // 🟢 DITAMBAHKAN: Simpan gambar permanen
                        profileImagePath.value = editingProfileImagePath.value;
                        box.write('profile_image_path', profileImagePath.value);

                        box.write('name', name.value);
                        box.write('email', email.value);

                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Your profile has been successfully updated.',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111E38),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void logout() {
    Get.offAllNamed(Routes.LOGIN);
  }

  void changePage(int index) {
    if (index == 4) return;

    switch (index) {
      case 0:
        Get.offAllNamed(Routes.DASHBOARD);
        break;

      case 1:
        Get.offAllNamed(Routes.INVENTORY);
        break;

      case 2:
        Get.toNamed(Routes.SCAN);
        break;

      case 3:
        Get.offAllNamed(Routes.MARKET);
        break;
    }
  }
}
