import 'dart:convert'; // 🔥 Wajib ditambahkan untuk jsonEncode
import 'package:get/get.dart';
import 'package:smart_sme_app/app/data/api_config.dart';

class AuthProvider extends GetConnect {
  // 👇 ALAMAT ASLI BACKEND LOKAL LAPTOPMU
  final String _baseUrl = '${ApiConfig.BASE_URL}/auth';

  @override
  void onInit() {
    baseUrl = _baseUrl;
    timeout = const Duration(seconds: 10);
    httpClient.defaultContentType = "application/json";
    
    // Tambahkan interceptor untuk log jaringan
    httpClient.addRequestModifier<dynamic>((request) {
      ApiConfig.logNetwork(request.url.toString());
      return request;
    });
    
    super.onInit();
  }

  // Fungsi Login ke Server
  Future<Response> login(String email, String password) => 
      post('/login', {'email': email, 'password': password}, headers: {'ngrok-skip-browser-warning': 'true'});

  // 1. 👇 FUNGSI BARU: Untuk tombol "Kirim OTP" (Alur No. 2)
  // Menembak endpoint FastAPI yang bertugas mengirim email berisi angka OTP
  Future<Response> requestRegisterOTP(String email) =>
      post('/request-otp', {'email': email}, headers: {'ngrok-skip-browser-warning': 'true'});

  // 2. 👇 PERBAIKAN FUNGSI REGISTER: Mengirim semua data SEKALIGUS (Alur No. 6)
  Future<Response> register(String name, String email, String password, String otp) {
    final Map<String, dynamic> rawBody = {
      'full_name': name, // 🔥 Diubah dari 'name' ke 'full_name'
      'email': email, 
      'password': password,
      'otp_code': otp    // 🔥 OTP ditambahkan di sini!
    };

    // 🔥 Proteksi jsonEncode agar GetConnect tidak mengubahnya jadi Form-Data
    return post(
      '/register', 
      jsonEncode(rawBody),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      }
    );
  }

  // -------------------------------------------------------------
  // Fungsi di bawah ini dibiarkan jika kamu juga pakai Google Login
  // -------------------------------------------------------------

  // sendGoogleDataForOTP(): Mengirim email dan id token Google ke backend
  Future<Response> sendGoogleDataForOTP(String email, String idToken) =>
      post('/google-otp', {
        'email': email,
        'token': idToken,
      }, headers: {'ngrok-skip-browser-warning': 'true'});

  // verifyOTP(): Mengirim kode OTP ke backend untuk divalidasi (Google Flow)
  Future<Response> verifyOTP(String email, String otpCode) =>
      post('/verify-otp', {
        'email': email,
        'otp': otpCode,
      }, headers: {'ngrok-skip-browser-warning': 'true'});
}
