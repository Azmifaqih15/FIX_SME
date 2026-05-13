import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,

        /// 🔥 LOGOUT BUTTON DI APPBAR
        actions: [
          IconButton(
            onPressed: () {
              final box = GetStorage();
              box.remove('isLogin');

              Get.snackbar("Info", "Berhasil logout");
              Get.offAllNamed('/login');
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              'HomeView is working 🚀',
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 30),

            /// 🔥 LOGOUT BUTTON (VERSI BESAR)
            ElevatedButton(
              onPressed: () {
                final box = GetStorage();
                box.remove('isLogin');

                Get.snackbar("Info", "Berhasil logout");
                Get.offAllNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}