import 'dart:convert'; // 🔥 WAJIB: Ditambahkan untuk menggunakan jsonEncode()
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get_storage/get_storage.dart'; 
import 'package:smart_sme_app/app/data/providers/auth_provider.dart';

class AuthService extends GetConnect {
  final LocalAuthentication auth = LocalAuthentication();
  final box = GetStorage(); // Inisialisasi local storage untuk menyimpan Token JWT
  final AuthProvider authProvider = Get.put(AuthProvider());

  @override
  void onInit() {
    // --- KETENTUAN UTS WEB SERVICE & JARINGAN LOKAL (FIXED IP) ---
    baseUrl = 'https://braden-noncrusading-uncarnivorously.ngrok-free.dev/api/v1'; 
    
    // Proteksi UTS Web Service
    timeout = const Duration(seconds: 10);
    httpClient.defaultContentType = "application/json";
    
    // 🛡️ IMPLEMENTASI KEAMANAN JARINGAN (JWT Injection)
    httpClient.addRequestModifier<dynamic>((request) {
      String? token = box.read('access_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
        print("🔒 [Keamanan Jaringan] Token Bearer disisipkan ke request otomatis!");
      }
      return request;
    });

    super.onInit();
  }

  // 1. HTTP POST Request Ke FastAPI untuk Google Login
  Future<Response> sendGoogleDataForOTP(String email, String idToken) async {
    final body = jsonEncode({"email": email, "id_token": idToken});
    print("Menembak API via Wi-Fi Lokal ke: $baseUrl/auth/google-login");
    return await post('/auth/google-login', body, headers: {
      'Content-Type': 'application/json', 
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    });
  }

  // HTTP POST Request Ke FastAPI untuk Google Login (Langsung ke Backend)
  Future<Response> googleLoginBackend(String email, String idToken) async {
    final body = jsonEncode({"email": email, "id_token": idToken});
    print("Menembak API via Wi-Fi Lokal ke: $baseUrl/auth/google-login");
    return await post('/auth/google-login', body, headers: {
      'Content-Type': 'application/json', 
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    });
  }

  // 1b. HTTP POST Request Ke FastAPI untuk Send OTP
  Future<Response> sendOTP(String email) async {
    final body = jsonEncode({"email": email});
    print("Menembak API via Wi-Fi Lokal ke: $baseUrl/auth/send-otp");
    return await post('/auth/send-otp', body, headers: {
      'Content-Type': 'application/json', 
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    });
  }

  // 2. HTTP POST Request Ke FastAPI untuk Verify OTP
  Future<Response> verifyOTP(String email, String otpCode) async {
    final body = jsonEncode({"email": email, "otp_code": otpCode});
    print("Menembak API via Wi-Fi Lokal ke: $baseUrl/auth/verify-otp");
    return await post('/auth/verify-otp', body, headers: {
      'Content-Type': 'application/json', 
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    });
  }

  /// 1. HTTP POST Request Ke FastAPI untuk LOGIN (Matkul: Web Service)
  Future<Response> loginUser(String email, String password) async {
    final body = jsonEncode({"email": email, "password": password});
    print("Menembak API via Wi-Fi Lokal ke: $baseUrl/auth/login");
    return await post('/auth/login', body, headers: {
      'Content-Type': 'application/json', 
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    });
  }

  // HTTP POST Request Ke FastAPI untuk Send Register OTP
  Future<Response> sendOtpRequest(String email) async {
    final body = jsonEncode({"email": email});
    print("Menembak API via Wi-Fi Lokal ke: $baseUrl/auth/request-otp");
    return await post('/auth/request-otp', body, headers: {
      'Content-Type': 'application/json', 
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    });
  }

  /// 🆕 2. HTTP POST Request Ke FastAPI untuk REGISTER (Matkul: Web Service)
  Future<Response> registerManual(String fullName, String email, String password, String otp) async {
    final Map<String, dynamic> rawBody = {
      "full_name": fullName,
      "email": email,
      "password": password,
      "otp_code": otp,
    };
    
    final String jsonBody = jsonEncode(rawBody);
    
    print("Menembak API via Wi-Fi Lokal ke: $baseUrl/auth/register");
    final response = await post(
      '/auth/register', 
      jsonBody, 
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      }
    );
    
    if (response.statusCode == 422) {
      print("ERROR 422 DARI SERVER: ${response.body}");
    }
    
    return response;
  }

  /// 🛡️ FUNGSI: Menyimpan token setelah login sukses (Keamanan Data)
  void saveToken(String token) {
    box.write('access_token', token);
    print("💾 [Keamanan Data] JWT Token berhasil disimpan di local storage HP!");
  }

  /// FUNGSI: Menghapus token saat user Logout
  void logout() {
    box.remove('access_token');
    print("🚪 Logout: Token JWT telah dihapus.");
  }

  /// 3. Autentikasi Biometrik Hardware (Matkul: Keamanan Data)
  Future<bool> authenticateBiometric() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        Get.snackbar("Info", "Perangkat ini tidak mendukung fitur biometrik");
        return false;
      }

      if (kIsWeb) return false;

      return await auth.authenticate(
        localizedReason: 'Scan wajah atau sidik jari untuk masuk ke Smart-SME',
        options: const AuthenticationOptions(
          biometricOnly: true, 
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      print("Error Sensor Biometrik: $e");
      return false;
    }
  }
}