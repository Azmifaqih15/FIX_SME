import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../inventory/controllers/inventory_controller.dart';
import 'package:image_picker/image_picker.dart';

class ScanController extends GetxController {
  // Reactive Variables
  var transactionType = 'IN'.obs;
  var selectedCategory = 'regular fit'.obs;
  var selectedSize = 'M'.obs;
  var quantity = 1.obs;
  var isLoading = false.obs;
  var selectedImagePath = ''.obs;

  // Scanner State (for debouncing/flagging)
  var isScanning = false.obs;
  MobileScannerController mobileScannerController = MobileScannerController();

  // Variations
  final List<String> categories = [
    'oversize',
    'fited',
    'fit body',
    'regular fit',
    'boxyfit'
  ];
  final List<String> sizes = ['S', 'M', 'L', 'XL', 'All Size'];

  // TextEditingControllers
  final skuController = TextEditingController();
  final descriptionController = TextEditingController();
  final colorController = TextEditingController();
  final priceController = TextEditingController();

  void incrementQty() {
    quantity.value++;
  }

  void decrementQty() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void onDetect(BarcodeCapture capture) {
    if (isScanning.value) return; // Mencegah scan berkali-kali secara beruntun

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        isScanning.value = true;
        skuController.text = barcode.rawValue!;

        Get.snackbar('Berhasil', 'Barcode terdeteksi: ${barcode.rawValue}',
            backgroundColor: Colors.green, colorText: Colors.white);

        // Reset flag setelah 2 detik agar bisa scan lagi nanti jika diperlukan
        Future.delayed(const Duration(seconds: 2), () {
          isScanning.value = false;
        });
        break; // Ambil barcode pertama yang valid
      }
    }
  }

  void resetForm() {
    transactionType.value = 'IN';
    selectedCategory.value = 'regular fit';
    selectedSize.value = 'M';
    quantity.value = 1;
    skuController.clear();
    descriptionController.clear();
    colorController.clear();
    priceController.clear();
  }

  Future<void> submitTransaction() async {
    if (skuController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        colorController.text.isEmpty) {
      Get.snackbar(
          'Peringatan', 'Harap isi semua field (SKU, Deskripsi, Warna)',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading(true);
      final url = Uri.parse(
          'https://braden-noncrusading-uncarnivorously.ngrok-free.dev/api/v1/transaction/scan');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'sku': skuController.text,
          'description': descriptionController.text,
          'category': selectedCategory.value,
          'size': selectedSize.value,
          'color': colorController.text,
          'type': transactionType.value,
          'quantity': quantity.value,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Sukses', 'Transaksi berhasil disimpan',
            backgroundColor: Colors.green, colorText: Colors.white);
        resetForm();

        // WAJIB panggil fetchProducts() untuk update data master
        if (Get.isRegistered<InventoryController>()) {
          Get.find<InventoryController>().fetchProducts();
        }
      } else {
        Get.snackbar('Gagal', 'Terjadi kesalahan: ${response.statusCode}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghubungi server',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImagePath.value = image.path;
    }
  }

  @override
  void onClose() {
    skuController.dispose();
    descriptionController.dispose();
    colorController.dispose();
    mobileScannerController.dispose();
    priceController.dispose();
    super.onClose();
  }
}
