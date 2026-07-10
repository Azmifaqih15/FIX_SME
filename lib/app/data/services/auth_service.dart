import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get_storage/get_storage.dart'; 
import 'package:smart_sme_app/app/data/providers/auth_provider.dart';
import 'package:smart_sme_app/app/data/api_config.dart';

class AuthService extends GetConnect {
  final LocalAuthentication auth = LocalAuthentication();
  final box = GetStorage(); // Inisialisasi local storage untuk menyimpan Token JWT
  final AuthProvider authProvider = Get.put(AuthProvider());

  @override
  void onInit() {
    // --- KETENTUAN UTS WEB SERVICE & JARINGAN LOKAL (FIXED IP) ---
    baseUrl = ApiConfig.BASE_URL; 
    
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
    ApiConfig.logNetwork('$baseUrl/auth/google');
    return await post('/auth/google', body, headers: {
      'Content-Type': 'application/json', 
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    });
  }

  // HTTP POST Request Ke FastAPI untuk Google Login (Langsung ke Backend)
  Future<Response> googleLoginBackend(String email, String idToken, [String? name]) async {
    final body = jsonEncode({"email": email, "id_token": idToken, "name": name});
    ApiConfig.logNetwork('$baseUrl/auth/google');
    return await post('/auth/google', body, headers: {
      'Content-Type': 'application/json', 
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    });
  }

  // 1b. HTTP POST Request Ke FastAPI untuk Send OTP
  Future<Response> sendOTP(String email) async {
    final body = jsonEncode({"email": email});
    ApiConfig.logNetwork('$baseUrl/auth/send-otp');
    return await post('/auth/send-otp', body, headers: {
      'Content-Type': 'application/json', 
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    });
  }

  // 2. HTTP POST Request Ke FastAPI untuk Verify OTP
  Future<Response> verifyOTP(String email, String otpCode) async {
    final body = jsonEncode({"email": email, "otp_code": otpCode});
    ApiConfig.logNetwork('$baseUrl/auth/verify-otp');
    return await post('/auth/verify-otp', body, headers: {
      'Content-Type': 'application/json', 
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    });
  }

  // HTTP POST Request Ke FastAPI untuk Verify OTP Lupa Password
  Future<Response> verifyResetOtp(String email, String otpCode) async {
    final body = jsonEncode({"email": email, "otp_code": otpCode});
    ApiConfig.logNetwork('$baseUrl/auth/verify-reset-otp');
    return await post('/auth/verify-reset-otp', body, headers: {
      'Content-Type': 'application/json', 
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    });
  }

  /// 1. HTTP POST Request Ke FastAPI untuk LOGIN (Matkul: Web Service)
  Future<Response> loginUser(String email, String password) async {
    final body = jsonEncode({"email": email, "password": password});
    ApiConfig.logNetwork('$baseUrl/auth/login');
    return await post('/auth/login', body, headers: {
      'Content-Type': 'application/json', 
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    });
  }

  // HTTP POST Request Ke FastAPI untuk Send Register OTP
  Future<Response> sendOtpRequest(String email) async {
    final body = jsonEncode({"email": email});
    ApiConfig.logNetwork('$baseUrl/auth/request-otp');
    return await post('/auth/request-otp', body, headers: {
      'Content-Type': 'application/json', 
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    });
  }

  /// 🆕 2. HTTP POST Request Ke FastAPI untuk REGISTER (Menggunakan http.MultipartRequest sesuai permintaan)
  Future<Response> registerManual(String fullName, String email, String password, String otp, {String? imagePath}) async {
    ApiConfig.logNetwork('$baseUrl/auth/register');
    
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/register'));
    
    // Menambahkan headers
    request.headers.addAll({
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    });

    // Menambahkan fields teks
    request.fields['name'] = fullName;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['otp_code'] = otp;

    // Menambahkan file gambar jika ada
    if (imagePath != null && imagePath.isNotEmpty) {
      var file = await http.MultipartFile.fromPath('profile_picture', imagePath);
      request.files.add(file);
    }

    // Eksekusi request
    var streamedResponse = await request.send();
    var responseData = await http.Response.fromStream(streamedResponse);

    // Konversi hasil balasan http menjadi GetConnect Response agar struktur return tidak rusak
    return Response(
      statusCode: responseData.statusCode,
      body: jsonDecode(responseData.body),
      bodyString: responseData.body,
      headers: responseData.headers,
    );
  }

  /// 🛡️ FUNGSI: Menyimpan token setelah login sukses (Keamanan Data)
  void saveToken(String token) {
    box.write('access_token', token);
    print("💾 [Keamanan Data] JWT Token berhasil disimpan di local storage HP!");
  }

  /// FUNGSI: Menghapus token saat user Logout
  Future<void> logout() async {
    final email = box.read('email');
    if (email != null) {
      try {
        final body = jsonEncode({"email": email});
        await post('/auth/logout', body, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
      } catch (_) {}
    }
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
