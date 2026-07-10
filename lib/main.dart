import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Import Service dan Route
import 'package:smart_sme_app/app/data/services/auth_service.dart'; // Pastikan path ini benar
import 'package:smart_sme_app/app/routes/app_pages.dart';

void main() async {
  // Memastikan binding framework Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Inisialisasi Local Storage (GetStorage)
  await GetStorage.init();

  // 🔥 Inisialisasi Global Service (Biometric / Auth)
  // Menggunakan permanent: true agar service tidak dihapus dari memori
  Get.put<AuthService>(AuthService(), permanent: true); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Smart-SME Infrastructure AI", // Sesuai nama proyek [cite: 1]
      debugShowCheckedModeBanner: false,

      // 🔥 Start dari Splash Screen [cite: 49]
      initialRoute: AppPages.INITIAL,

      // 🔥 Semua Route yang sudah didefinisikan
      getPages: AppPages.routes,

      // 🔥 Fallback jika rute tidak ditemukan
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const Scaffold(
          body: Center(
            child: Text("404 - Halaman Tidak Ditemukan"),
          ),
        ),
      ),

      // 🔥 Tema Dasar Aplikasi
      // Menggunakan Material 3 sesuai standar pengembangan mobile modern [cite: 42, 52]
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
    );
  }
}
