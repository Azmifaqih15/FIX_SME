import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../inventory/controllers/inventory_controller.dart';
import '../../activity_log/controllers/activity_log_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_pages.dart';
import 'package:smart_sme_app/app/data/api_config.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../notification/controllers/notification_controller.dart';
import 'package:get_storage/get_storage.dart';

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
  final hargaBeliController = TextEditingController();
  final hargaJualController = TextEditingController();
  final qtyTextController = TextEditingController(text: '1');

  void incrementQty() {
    quantity.value++;
    qtyTextController.text = quantity.value.toString();
  }

  void decrementQty() {
    if (quantity.value > 1) {
      quantity.value--;
      qtyTextController.text = quantity.value.toString();
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
    hargaBeliController.clear();
    hargaJualController.clear();
    qtyTextController.text = '1';
  }

  Future<void> submitTransaction() async {
    if (skuController.text.isEmpty) {
      Get.snackbar(
          'Peringatan', 'Harap isi SKU terlebih dahulu',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      // Ganti sesuai host backend Anda
      final fullUrl = '${ApiConfig.BASE_URL}/inventory/scan';
      ApiConfig.logNetwork(fullUrl);
      final url = Uri.parse(fullUrl);
      var request = http.MultipartRequest('POST', url);
      final box = GetStorage();
      final String? token = box.read('access_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['ngrok-skip-browser-warning'] = 'true';

      // Persiapan Data Wajib
      request.fields['sku'] = skuController.text;
      request.fields['scan_type'] = transactionType.value.toLowerCase();
      request.fields['qty'] = quantity.value.toString();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      if (userId != null) {
        request.fields['user_id'] = userId;
      }

      // Persiapan Data Opsional
      if (selectedCategory.value.isNotEmpty) request.fields['category'] = selectedCategory.value;
      if (selectedSize.value.isNotEmpty) request.fields['size'] = selectedSize.value;
      if (colorController.text.isNotEmpty) request.fields['color'] = colorController.text;
      
      if (transactionType.value == 'IN' && hargaBeliController.text.isNotEmpty) {
        String cleanPrice = hargaBeliController.text.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanPrice.isNotEmpty) request.fields['price'] = cleanPrice;
      }
      
      if (transactionType.value == 'OUT' && hargaJualController.text.isNotEmpty) {
        String cleanSellingPrice = hargaJualController.text.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanSellingPrice.isNotEmpty) request.fields['selling_price'] = cleanSellingPrice;
      }

      // Sisipkan foto jika ada HANYA saat Stock In
      if (transactionType.value == 'IN' && selectedImagePath.value.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('product_image', selectedImagePath.value)
        );
      }

      // Eksekusi API
      var streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Berhasil
        Get.snackbar('Sukses', 'Data berhasil masuk',
            backgroundColor: Colors.green, colorText: Colors.white);
            
        // SANGAT PENTING: Update state lokal secara real-time sebelum fetch
        if (Get.isRegistered<InventoryController>()) {
          var invCtrl = Get.find<InventoryController>();
          int change = transactionType.value == 'IN' ? quantity.value : -quantity.value;
          invCtrl.updateStockLocally(skuController.text, change);
          // Refresh sinkronisasi backend di latar belakang (tanpa await agar UI tidak nge-freeze)
          invCtrl.fetchInventory();
        }
        
        // Refresh Activity Log jika controller aktif
        if (Get.isRegistered<ActivityLogController>()) {
          Get.find<ActivityLogController>().fetchLogs();
        }

        // Refresh Dashboard Profit Chart (Performa Penjualan)
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchMonthlyProfit();
        }

        // Refresh Notifications
        if (Get.isRegistered<NotificationController>()) {
          Get.find<NotificationController>().fetchNotifications();
        }

        // Baru setelah itu bersihkan form input
        resetForm();
        selectedImagePath.value = '';
        
        // Pindah ke halaman Inventory
        Get.toNamed(Routes.INVENTORY);
      } else {
        // Gagal (400 / 404 / 500 dll)
        String errorMsg = 'Terjadi kesalahan pada server';
        try {
          var jsonResponse = jsonDecode(response.body);
          // Mengambil pesan asli dari backend (biasanya di key 'detail' atau 'message')
          errorMsg = jsonResponse['detail'] ?? jsonResponse['message'] ?? errorMsg;
        } catch (_) {}
        
        Get.snackbar('Gagal', errorMsg,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error Backend', e.toString(), 
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI BARU UNTUK SUBMIT PRODUCT DENGAN MULTIPART REQUEST ---
  Future<void> submitProduct() async {
    // Validasi dasar
    if (skuController.text.isEmpty || descriptionController.text.isEmpty) {
      Get.snackbar('Peringatan', 'Harap isi SKU dan Deskripsi',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      // Ganti URL dengan endpoint backend yang sesuai untuk input barang
      final fullUrl = '${ApiConfig.BASE_URL}/products';
      ApiConfig.logNetwork(fullUrl);
      final url = Uri.parse(fullUrl);
          
      var request = http.MultipartRequest('POST', url);
      final box = GetStorage();
      final String? token = box.read('access_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['ngrok-skip-browser-warning'] = 'true';

      // 3. Isi request.fields persis sesuai kunci yang diminta
      request.fields['sku'] = skuController.text;
      request.fields['name'] = descriptionController.text;
      request.fields['category'] = selectedCategory.value;
      request.fields['size'] = selectedSize.value;
      request.fields['color'] = colorController.text;
      String cleanPrice = hargaBeliController.text.replaceAll(RegExp(r'[^0-9]'), '');
      request.fields['price'] = cleanPrice.isEmpty ? '0' : cleanPrice;
      request.fields['qty'] = quantity.value.toString();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      if (userId != null) {
        request.fields['user_id'] = userId;
      }

      // 4. Tambahkan foto ke request.files jika user memilih foto
      if (selectedImagePath.value.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('product_image', selectedImagePath.value)
        );
      }

      // 5. Kirim request
      var streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      var response = await http.Response.fromStream(streamedResponse);

      // 6. Cek respon 200/201
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Tampilkan Snackbar sukses
        Get.snackbar('Sukses', 'Barang berhasil ditambahkan!',
            backgroundColor: Colors.green, colorText: Colors.white);

        // Trigger refresh halaman Inventory (dengan await)
        if (Get.isRegistered<InventoryController>()) {
          await Get.find<InventoryController>().fetchInventory();
        }

        // Refresh Activity Log
        if (Get.isRegistered<ActivityLogController>()) {
          Get.find<ActivityLogController>().fetchLogs();
        }

        // Refresh Notifications
        if (Get.isRegistered<NotificationController>()) {
          Get.find<NotificationController>().fetchNotifications();
        }

        // Bersihkan semua form
        resetForm();
        selectedImagePath.value = '';

        // Arahkan user ke halaman Inventory
        Get.toNamed(Routes.INVENTORY);
      } else {
        Get.snackbar('Gagal', 'Terjadi kesalahan: ${response.statusCode} - ${response.body}',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error Backend', e.toString(), 
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
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
    hargaBeliController.dispose();
    hargaJualController.dispose();
    qtyTextController.dispose();
    super.onClose();
  }
}
