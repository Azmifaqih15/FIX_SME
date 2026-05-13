import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      // Pengecekan apakah perangkat mendukung biometrik
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        Get.snackbar("Info", "Perangkat tidak mendukung biometrik");
        return false;
      }

      // Web tidak didukung oleh package local_auth saat ini
      if (kIsWeb) return false; 

      return await auth.authenticate(
        localizedReason: 'Scan wajah atau sidik jari untuk login ke Smart-SME',
        options: const AuthenticationOptions(
          biometricOnly: true, // Hanya mengizinkan biometrik (bukan PIN/Pattern)
          stickyAuth: true,    // Tetap mencoba autentikasi jika aplikasi ke background
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      print("Error Biometrik: $e");
      return false;
    }
  }
}