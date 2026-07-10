import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BusinessInfoController extends GetxController {
  // Key untuk validasi form
  final formKey = GlobalKey<FormState>();

  // Controller untuk masing-masing input teks
  final storeNameCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final warehouseCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() {
    // Data dummy yang relevan dengan UMKM Fashion (Smart-SME)
    storeNameCtrl.text = "Smart-SME Fashion Hub";
    categoryCtrl.text = "Apparel & Clothing";
    phoneCtrl.text = "+62 812-3456-7890";
    addressCtrl.text = "Jl. Sudirman No. 123, Jakarta Selatan, 12190";
    warehouseCtrl.text = "Gudang Utama - Blok A2";
  }

  void saveChanges() {
    // Mengecek apakah semua form sudah diisi
    if (formKey.currentState!.validate()) {
      // Logika untuk menyimpan ke API atau database lokal nanti diletakkan di sini

      Get.back(); // Kembali ke halaman sebelumnya
      Get.snackbar(
        "Success",
        "Business information updated successfully.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  @override
  void onClose() {
    // Bersihkan memori saat halaman ditutup
    storeNameCtrl.dispose();
    categoryCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    warehouseCtrl.dispose();
    super.onClose();
  }
}
