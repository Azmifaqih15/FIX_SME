import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/scan_controller.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class ScanView extends GetView<ScanController> {
  const ScanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Transaksi'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Get.previousRoute.isNotEmpty) {
              Get.back();
            } else {
              Get.offAllNamed('/dashboard');
            }
          },
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          if (Get.previousRoute.isNotEmpty) {
            Get.back();
          } else {
            Get.offAllNamed('/dashboard');
          }
        },
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kamera Embedded
              SizedBox(
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: controller.mobileScannerController,
                        onDetect: controller.onDetect,
                      ),
                      // Overlay scan indicator (opsional tapi bagus untuk UX)
                      if (controller.isScanning.value)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Tipe Transaksi
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            controller.transactionType.value == 'IN'
                                ? Colors.green
                                : Colors.grey.shade300,
                        foregroundColor:
                            controller.transactionType.value == 'IN'
                                ? Colors.white
                                : Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => controller.transactionType.value = 'IN',
                      child: const Text('Stock In',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            controller.transactionType.value == 'OUT'
                                ? Colors.red
                                : Colors.grey.shade300,
                        foregroundColor:
                            controller.transactionType.value == 'OUT'
                                ? Colors.white
                                : Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => controller.transactionType.value = 'OUT',
                      child: const Text('Stock Out',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form Input: SKU
              TextField(
                controller: controller.skuController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'SKU / Barcode',
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),



              // Form Input: Kategori Dropdown
              DropdownButtonFormField<String>(
                value: controller.selectedCategory.value,
                decoration: InputDecoration(
                  labelText: 'Kategori (Fit)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: controller.categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.selectedCategory.value = newValue;
                  }
                },
              ),
              const SizedBox(height: 16),

              // Form Input: Size Dropdown
              DropdownButtonFormField<String>(
                value: controller.selectedSize.value,
                decoration: InputDecoration(
                  labelText: 'Size',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: controller.sizes.map((String size) {
                  return DropdownMenuItem<String>(
                    value: size,
                    child: Text(size),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.selectedSize.value = newValue;
                  }
                },
              ),
              const SizedBox(height: 16),

              // Form Input: Warna
              TextField(
                controller: controller.colorController,
                decoration: InputDecoration(
                  labelText: 'Warna',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Form Input: Harga Beli / Modal (Stock In) atau Harga Jual (Stock Out)
              Obx(() {
                if (controller.transactionType.value == 'IN') {
                  return Column(
                    children: [
                      TextField(
                        controller: controller.hargaBeliController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Harga Beli / Modal',
                          prefixText: 'Rp ',
                          prefixStyle: const TextStyle(
                              color: Colors.black87, fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF4F46E5), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      TextField(
                        controller: controller.hargaJualController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Harga Jual',
                          prefixText: 'Rp ',
                          prefixStyle: const TextStyle(
                              color: Colors.black87, fontWeight: FontWeight.bold),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF4F46E5), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
              }),

              // 🟢 --- KODE BARU: AREA UPLOAD GAMBAR ---
              Obx(() {
                if (controller.transactionType.value == 'IN') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Foto Produk",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => controller.pickImage(),
                        child: Builder(builder: (context) {
                          final imagePath = controller.selectedImagePath.value;
                          return Container(
                            height: 100, // Tinggi area foto produk
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                style: imagePath.isEmpty
                                    ? BorderStyle.solid
                                    : BorderStyle.none,
                              ),
                            ),
                            child: imagePath.isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined,
                                          size: 40, color: Colors.grey[400]),
                                      const SizedBox(height: 8),
                                      Text("Tap to upload product image",
                                          style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12)),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(imagePath),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                } else {
                  return const SizedBox.shrink(); // Hilangkan Form Jika OUT
                }
              }),

              // Pengatur Qty
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Quantity:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: controller.decrementQty,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: SizedBox(
                            width: 60,
                            child: TextField(
                              controller: controller.qtyTextController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              onChanged: (val) {
                                int parsed = int.tryParse(val) ?? 1;
                                if (parsed < 1) parsed = 1;
                                controller.quantity.value = parsed;
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: controller.incrementQty,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Tombol Submit Paling Bawah
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        controller.submitTransaction();
                      },
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
