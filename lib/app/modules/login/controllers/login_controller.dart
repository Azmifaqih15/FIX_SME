import 'dart:convert'; // <- IMPORT SUDAH DIPINDAHKAN KE SINI (WAJIB PADA DART)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_sme_app/app/data/services/auth_service.dart';

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

      // Print debug untuk melihat data asli dari server di terminal VS Code
      print("STATUS CODE DARI SERVER: ${response.statusCode}");
      print("BODY DARI SERVER: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.body;
        
        // Proteksi jika data yang kembali berupa string mentah
        if (data is String) {
          data = jsonDecode(data);
        }

        // Ambil data dari JSON objek secara aman
        String token = data['access_token'] ?? "";
        String name = data['user'] != null ? data['user']['name'] : "User";
        String userEmail = data['user'] != null ? data['user']['email'] : email.value;

        // --- SEKTOR KEAMANAN DATA (UTS): Simpan Sesi Enkripsi JWT ---
        box.write('isLogin', true);
        box.write('name', name);
        box.write('email', userEmail);
        
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

  /// 2. EKSEKUSI TOMBOL FACE ID LOGIN (Hardware Biometric)
  Future<void> loginWithFaceID() async {
    try {
      isLoading.value = true;
      bool isAuthenticated = await authService.authenticateBiometric();
      isLoading.value = false;

      if (isAuthenticated) {
        box.write('isLogin', true);
        box.write('name', 'SME Owner (Biometric)');
        
        Get.snackbar("Sukses Biometrik", "Login Face ID Berhasil!");
        Get.offAllNamed('/dashboard');
      } else {
        Get.snackbar("Gagal", "Autentikasi wajah/sidik jari ditolak atau dibatalkan");
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Terjadi kesalahan pada sensor biometrik");
    }
  }

  /// 3. EKSEKUSI TOMBOL LOGIN GOOGLE
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      
      // Memaksa pembersihan sesi agar pop-up pemilihan akun selalu muncul
      await googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User membatalkan login
        Get.snackbar("Info", "Login dibatalkan oleh pengguna");
        return;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken ?? googleAuth.accessToken;
      final String emailAddress = googleUser.email;
      
      if (idToken == null) {
        Get.snackbar(
          "Gagal", 
          "Gagal mendapatkan token autentikasi dari Google",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white
        );
        return;
      }
      
      // Kirim data Google ke FastAPI backend
      final response = await authService.googleLoginBackend(emailAddress, idToken);
      
      print("Google Login Status: ${response.statusCode}");
      print("Google Login Response: ${response.body}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.body;
        
        // Coba simpan token dan sesi jika data dari server menyediakan
        try {
          if (data is String) {
            data = jsonDecode(data);
          }
          if (data != null) {
            String token = data['access_token'] ?? "";
            String name = data['user'] != null ? data['user']['name'] : "User";
            
            box.write('isLogin', true);
            box.write('name', name);
            box.write('email', emailAddress);
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
      print("Google Sign In Error: $e");
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
    box.write('name', 'Developer (Windows)');
    box.write('email', 'dev@windows.local');

    // Langsung arahkan ke dashboard
    Get.offAllNamed('/dashboard');
  }
}