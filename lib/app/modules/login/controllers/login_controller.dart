import 'dart:convert'; // <- IMPORT SUDAH DIPINDAHKAN KE SINI (WAJIB PADA DART)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_sme_app/app/data/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:smart_sme_app/app/data/api_config.dart';
import 'auto_face_login_controller.dart';
import '../views/auto_face_login_view.dart';

class LoginController extends GetxController {
  final box = GetStorage();
  late AuthService authService;

  // Rx State untuk memantau perubahan UI secara Real-time
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi AuthService secara aman
    try {
      authService = Get.find<AuthService>();
    } catch (e) {
      authService = Get.put(AuthService());
    }
  }

  // Fungsi toggle icon mata di form password
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// 1. EKSEKUSI TOMBOL LOGIN (REST API ke FastAPI)
  Future<void> loginWithCredentials() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar("Peringatan", "Email dan Password tidak boleh kosong!");
      return;
    }

    try {
      isLoading.value = true;

      // Jalankan fungsi HTTP Post dari Service
      final response = await authService.loginUser(email.value.trim(), password.value.trim());

      print("=== RESPONSE DARI BACKEND ===");
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.body;
        
        // Proteksi jika data yang kembali berupa string mentah
        if (data is String) {
          data = jsonDecode(data);
        }

        // Ambil data dari JSON objek secara aman (sekarang berada di dalam key 'data')
        String token = data['access_token'] ?? "";
        String name = data['data'] != null ? data['data']['name'] : "User";
        String userEmail = data['data'] != null && data['data']['email'] != null ? data['data']['email'] : email.value;
        String photoUrl = data['data'] != null && data['data']['photo_url'] != null ? data['data']['photo_url'] : "";
        
        var userIdRaw = data['data'] != null ? data['data']['id'] : null;
        String userIdStr = userIdRaw != null ? userIdRaw.toString() : "";

        print("Menyimpan ke memori -> Nama: $name, Foto: $photoUrl, ID: $userIdStr");

        // --- SEKTOR KEAMANAN DATA (UTS): Simpan Sesi Enkripsi JWT ---
        await box.write('isLogin', true);
        await box.write('is_google_login', false);
        await box.write('user_name', name);
        await box.write('email', userEmail);
        await box.write('user_photo', photoUrl);
        
        if (userIdStr.isNotEmpty) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userIdStr);
        }

        // ⚠️ UPDATE PENTING: Panggil fungsi dari AuthService agar kunci penyimpanannya sinkron 
        // dan bisa dipakai otomatis untuk request jaringan selanjutnya.
        authService.saveToken(token);

        Get.snackbar("Sukses", "Selamat datang kembali, $name");
        
        // Pindah ke Dashboard
        Get.offAllNamed('/dashboard'); 
      } else {
        var data = response.body;
        String errorDetail = "Email atau Password salah";
        
        if (data != null) {
          if (data is String) {
            data = jsonDecode(data);
          }
          errorDetail = data['detail'] ?? "Email atau Password salah";
        }
        
        Get.snackbar("Gagal Masuk", errorDetail);
      }
    } catch (e) {
      print("ERROR CRASH DI FLUTTER: $e");
      Get.snackbar("Masalah Jaringan", "Gagal menyambung atau membaca data backend FastAPI.");
    } finally {
      isLoading.value = false;
    }
  }

  /// 2. EKSEKUSI TOMBOL FACE ID LOGIN (FaceNet - Auto Capture Camera)
  Future<void> loginWithFaceID() async {
    Get.to(
      () => const AutoFaceLoginView(),
      binding: BindingsBuilder(() {
        Get.put(AutoFaceLoginController());
      }),
    );
  }

  /// 3. EKSEKUSI TOMBOL LOGIN GOOGLE
  Future<void> loginWithGoogle() async {
    try {
      print('=== START GOOGLE LOGIN ===');
      print('1. Memulai proses GoogleSignIn...');
      
      isLoading.value = true;
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      
      // Memaksa pembersihan sesi agar pop-up pemilihan akun selalu muncul
      await googleSignIn.signOut();
      
      // Lakukan proses GoogleSignIn
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        print('1b. Login dibatalkan oleh user (googleUser is null)');
        Get.snackbar("Info", "Login dibatalkan oleh pengguna");
        isLoading.value = false;
        return;
      }
      
      print('2. Berhasil login Google, mengambil Auth properties...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken ?? googleAuth.accessToken;
      final String emailAddress = googleUser.email;
      final String? displayName = googleUser.displayName;
      
      if (idToken == null) {
        print('ERROR: idToken dari Google kosong!');
        Get.snackbar(
          "Gagal", 
          "Gagal mendapatkan token autentikasi dari Google",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white
        );
        isLoading.value = false;
        return;
      }
      
      print('3. Token berhasil didapat (length: ${idToken.length}). Mengirim ke Backend...');
      print('URL Target: https://backend-sme.up.railway.app/api/v1/auth/google-login');
      
      // Kirim data Google ke FastAPI backend
      final response = await authService.googleLoginBackend(emailAddress, idToken, displayName);
      
      print('4. Request terkirim! Menunggu respons...');
      print('5. Respons Backend: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.body;
        
        // Coba simpan token dan sesi jika data dari server menyediakan
        try {
          if (data is String) {
            data = jsonDecode(data);
          }
          if (data != null) {
            String token = data['access_token'] ?? "";
            String name = data['data'] != null ? data['data']['name'] : "User";
            var userIdRaw = data['data'] != null ? data['data']['id'] : null;
            String userIdStr = userIdRaw != null ? userIdRaw.toString() : "";
            
            box.write('isLogin', true);
            box.write('is_google_login', true);
            box.write('user_name', name);
            box.write('email', emailAddress);
            if (userIdStr.isNotEmpty) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_id', userIdStr);
            }
            if (token.isNotEmpty) {
              authService.saveToken(token);
            }
          }
        } catch (_) {}

        Get.snackbar(
          "Sukses", 
          "Login Google Berhasil", 
          backgroundColor: Colors.green, 
          colorText: Colors.white
        );
        
        // Pindah paksa ke Halaman Dashboard
        Get.offAllNamed('/dashboard');
      } else {
        var data = response.body;
        String errorDetail = "Gagal memproses login Google di server";
        
        if (data != null) {
          try {
            if (data is String) {
              data = jsonDecode(data);
            }
          } catch (_) {}
          
          if (data is Map) {
            errorDetail = data['detail'] ?? errorDetail;
          }
        }
        
        Get.snackbar(
          "Gagal", 
          errorDetail, 
          backgroundColor: Colors.redAccent, 
          colorText: Colors.white
        );
      }
    } catch (e) {
      print('=== ERROR GOOGLE LOGIN FLUTTER ===');
      print(e.toString());
      Get.snackbar(
        "Error", 
        "Terjadi kesalahan jaringan atau batal saat Login dengan Google: $e", 
        backgroundColor: Colors.redAccent, 
        colorText: Colors.white
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 4. EKSEKUSI TOMBOL DEVELOPER (Bypass Login khusus Windows)
  void loginAsDeveloper() {
    Get.snackbar(
      "Mode Developer", 
      "Login berhasil dilewati. Memasuki Dashboard...", 
      backgroundColor: Colors.blueGrey, 
      colorText: Colors.white
    );

    // Set mock data session sementara untuk mengelabui pengecekan middleware/sesi
    box.write('isLogin', true);
    box.write('user_name', 'Developer (Windows)');
    box.write('email', 'dev@windows.local');

    // Langsung arahkan ke dashboard
    Get.offAllNamed('/dashboard');
  }
}
