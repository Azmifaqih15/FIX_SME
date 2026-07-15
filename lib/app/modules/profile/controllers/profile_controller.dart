import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart'; 
import '../../../routes/app_pages.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../inventory/controllers/inventory_controller.dart';
import 'package:smart_sme_app/app/data/api_config.dart';
import 'package:smart_sme_app/app/data/services/auth_service.dart' as smart_sme_auth;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileController extends GetxController {
  final box = GetStorage();
  final ImagePicker _picker = ImagePicker();

  var name = "John Doe".obs;
  var email = "john@business.com".obs;
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

    loadUserData();

  }

  Future<void> loadUserData() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final storedName = box.read('user_name');
    final storedEmail = box.read('email');
    // 🟢 DITAMBAHKAN: Membaca gambar profil yang tersimpan
    final storedImagePath = box.read('user_photo');

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

    update(); // Paksa UI untuk render ulang
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
                                    : (path.startsWith('http')
                                        ? Image.network(
                                            path,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(path),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )),
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
                        
                        // Tutup bottom sheet form terlebih dahulu
                        Get.back();
                        
                        // Panggil fungsi submitEditProfile yang dibuat khusus
                        submitEditProfile(
                          nameCtrl.text.trim(), 
                          editingProfileImagePath.value
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

  // --- FUNGSI BARU UNTUK SUBMIT EDIT PROFILE ---
  Future<void> submitEditProfile(String newName, String newPhotoPath) async {
    // Tampilkan loading screen (menggunakan Get.dialog)
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final fullUrl = '${ApiConfig.BASE_URL}/auth/update-profile';
      ApiConfig.logNetwork(fullUrl);
      var request = http.MultipartRequest('POST', Uri.parse(fullUrl));
      request.headers.addAll({'Accept': 'application/json'});
      
      request.fields['name'] = newName;
      
      // Mengambil email dari memori HP (sesuai instruksi)
      String storedEmail = box.read('email') ?? email.value;
      request.fields['email'] = storedEmail;

      // Jika ada file foto baru yang dipilih
      if (newPhotoPath.isNotEmpty && !newPhotoPath.startsWith('http')) {
        String fileName = newPhotoPath.split('/').last;
        if (!fileName.contains('.')) {
          fileName = '$fileName.jpg';
        }
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture', 
          newPhotoPath,
          filename: fileName,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        
        // Ekstrak name dan photo_url dari JSON response
        String? serverUrl = jsonResponse['data']?['photo_url'];
        String newPhotoUrl = (serverUrl != null && serverUrl.toString().startsWith('http')) 
            ? serverUrl 
            : newPhotoPath;
            
        String serverName = jsonResponse['data']?['name'] ?? newName;
        
        // SIMPAN KE MEMORI: Timpa data lama
        await box.write('user_photo', newPhotoUrl);
        await box.write('user_name', serverName);
        
        // BROADCAST PERUBAHAN (SANGAT PENTING)
        if (Get.isRegistered<DashboardController>()) {
           var dashCtrl = Get.find<DashboardController>();
           dashCtrl.userName.value = serverName;
           dashCtrl.userPhoto.value = newPhotoUrl;
        }
        if (Get.isRegistered<InventoryController>()) {
           var invCtrl = Get.find<InventoryController>();
           invCtrl.userPhoto.value = newPhotoUrl;
        }
        
        // Update controller ini juga
        name.value = serverName;
        profileImagePath.value = newPhotoUrl;
        
        Get.back(); // Tutup loading dialog
        
        // Tampilkan Snackbar hijau
        Get.snackbar(
          'Sukses',
          'Profil diupdate',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.back(); // Tutup loading dialog
        Get.snackbar("Gagal", "Error: ${response.statusCode}",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.back(); // Tutup loading dialog
      Get.snackbar("Error", "Gagal menghubungi server: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Deklarasi plugin di tingkat class
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // --- FUNGSI TEST NOTIFIKASI SEMENTARA ---
  Future<void> testLocalNotification() async {
    try {
      // 1. Meminta izin (Permission) Notifikasi
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        status = await Permission.notification.request();
      }

      if (status.isGranted) {
        // 2. Inisialisasi plugin
        const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
        const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
        
        await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);

        // 3. Konfigurasi Notifikasi
        const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'test_channel_id',
          'Test Channel',
          channelDescription: 'Channel untuk testing notifikasi',
          importance: Importance.max,
          priority: Priority.high,
        );
        const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

        // 4. Memunculkan notifikasi
        await flutterLocalNotificationsPlugin.show(
          id: 0,
          title: 'Cek Sistem 🚀',
          body: 'Sistem notifikasi aplikasi berjalan dengan normal dan lancar!',
          notificationDetails: platformChannelSpecifics,
        );
        
        print('Notifikasi berhasil dipanggil');
      } else {
        print('Izin notifikasi ditolak oleh pengguna');
        Get.snackbar("Akses Ditolak", "Izinkan notifikasi di pengaturan HP Anda.");
      }
    } catch (e) {
      print('Error Notifikasi: $e');
    }
  }

  Future<void> logout() async {
    try {
      final authService = Get.find<smart_sme_auth.AuthService>();
      await authService.logout();
    } catch (_) {}
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
