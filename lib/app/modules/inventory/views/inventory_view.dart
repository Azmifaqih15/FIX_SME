import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/inventory_controller.dart';
import 'dart:io';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() => CircleAvatar(
                backgroundColor: const Color(0xFF1E293B),
                backgroundImage: controller.userPhoto.value.isNotEmpty
                    ? NetworkImage(controller.userPhoto.value)
                    : null,
                child: controller.userPhoto.value.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              )),
        ),
        title: const Text(
          "T-Shirt Collection",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {
                Get.toNamed(Routes.NOTIFICATION);
              }),
        ],
      ),
      // --- BARIS INI TELAH DIHAPUS (floatingActionButton: _buildFab(context),) ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) => controller.fetchInventory(query: value),
              decoration: InputDecoration(
                hintText: "Search T-Shirt style...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Tabs untuk Filter Fit
            SizedBox(
              height: 35,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                itemBuilder: (context, index) => Obx(() {
                  bool isSelected = controller.selectedCategory.value ==
                      controller.categories[index];
                  return GestureDetector(
                    onTap: () => controller.selectedCategory.value =
                        controller.categories[index],
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          controller.categories[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // Grid T-Shirt
            Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (controller.filteredProducts.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50.0),
                  child: Center(
                    child: Text(
                      'Gudang Kosong. Silakan lakukan Scan In terlebih dahulu.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.72,
                ),
                itemCount: controller.filteredProducts.length,
                itemBuilder: (context, index) {
                  var product = controller.filteredProducts[index];
                  return _buildProductCard(product);
                },
              );
            }),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- FUNGSI _buildFab JUGA TELAH DIHAPUS KARENA TIDAK TERPAKAI LAGI ---

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.grid_view_rounded, "Dashboard", 0),
          _buildNavItem(Icons.inventory_2_outlined, "Inventory", 1,
              isActive: true),
          _buildNavItem(Icons.qr_code_scanner_outlined, "Scan", 2),
          _buildNavItem(Icons.analytics_outlined, "Market", 3),
          _buildNavItem(Icons.person_outline, "Profile", 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index,
      {bool isActive = false}) {
    return GestureDetector(
      onTap: () => controller.changePage(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isActive ? const Color(0xFF1E293B) : Colors.grey[400],
              size: 22),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color:
                      isActive ? const Color(0xFF1E293B) : Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    String statusStr;
    Color statusColor;

    if (product.qty == 0) {
      statusStr = 'Dead Stock';
      statusColor = Colors.grey;
    } else if (product.qty <= 5) {
      statusStr = 'Critical';
      statusColor = Colors.red;
    } else if (product.qty <= 15) {
      statusStr = 'Warning';
      statusColor = Colors.orange;
    } else {
      statusStr = 'Normal';
      statusColor = Colors.green;
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Get.toNamed(Routes.PRODUCT_DETAIL, arguments: product);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: product.image.trim().isNotEmpty
                        ? Image.network(
                            product.image.trim(),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.image, color: Colors.grey, size: 50),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.category,
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              statusStr,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Rp ${product.price}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Stock: ${product.qty}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              _iconAction(
                icon: Icons.edit_outlined,
                onTap: () => _openEditSheet(product),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                  onPressed: () => _confirmDelete(product.id),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconAction({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: (color ?? Colors.white).withOpacity(0.92),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: color ?? Colors.black,
        ),
      ),
    );
  }

  void _confirmDelete(int id) {
    Get.defaultDialog(
      title: 'Delete product?',
      middleText: 'Produk akan dihapus dari inventory.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFDC2626),
      cancelTextColor: Colors.black,
      onConfirm: () {
        controller.deleteProduct(id);
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

  void _openCreateSheet() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    String selectedCategory = controller.categories[1];
    String selectedStatus = 'NORMAL';

    // Reset gambar saat sheet baru dibuka
    controller.resetImage();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: _sheetContainer(
              title: 'Add Product',
              child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18, left: 6, right: 6),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- AREA UPLOAD GAMBAR ---
                      GestureDetector(
                        onTap: () => controller.pickImage(),
                        child: Obx(() {
                          final imagePath = controller.selectedImagePath.value;
                          return Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
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
                                          size: 40, color: Colors.grey[500]),
                                      const SizedBox(height: 8),
                                      Text("Tap to upload product image",
                                          style: TextStyle(
                                              color: Colors.grey[600],
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
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items: controller.categories
                            .where((e) => e != 'All Items')
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(
                            () => selectedCategory = v ?? selectedCategory),
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Qty'),
                        validator: (v) {
                          final s = v?.trim() ?? '';
                          final n = int.tryParse(s);
                          if (n == null) return 'Qty must be a number';
                          if (n < 0) return 'Qty must be >= 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        items: ['NORMAL', 'WARNING', 'CRITICAL', 'DEAD STOCK']
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(controller.statusLabel(e))))
                            .toList(),
                        onChanged: (v) => setState(
                            () => selectedStatus = v ?? selectedStatus),
                        decoration: const InputDecoration(labelText: 'Status'),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;

                            // Opsional: Validasi apakah gambar sudah dipilih
                            if (controller.selectedImagePath.value.isEmpty) {
                              Get.snackbar("Info",
                                  "Pilih gambar produk terlebih dahulu.",
                                  snackPosition: SnackPosition.BOTTOM);
                              return;
                            }

                            controller.addProduct(
                              name: nameCtrl.text.trim(),
                              category: selectedCategory.toUpperCase(),
                              qty: int.parse(qtyCtrl.text.trim()),
                              status: selectedStatus,
                              imagePath: controller
                                  .selectedImagePath.value, // Kirim path lokal
                            );
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Create'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _openEditSheet(Product product) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: product.name);
    final qtyCtrl = TextEditingController(text: product.qty.toString());
    final priceCtrl = TextEditingController(text: product.price.toString());
    final imageCtrl = TextEditingController(text: product.image);

    String selectedCategory = product.category.replaceAll('_', ' ');
    selectedCategory = selectedCategory
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');

    if (!controller.categories.contains(selectedCategory)) {
      selectedCategory = controller.categories[1];
    }

    String selectedStatus = product.status.isEmpty ? 'NORMAL' : product.status;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Form(
            key: formKey,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // WAJIB ADA
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Product',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Image Area (Read-Only)
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: controller.categories
                          .where((e) => e != 'All Items')
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(
                          () => selectedCategory = v ?? selectedCategory),
                      decoration:
                          const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga',
                        prefixText: 'Rp ', 
                      ),
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.isEmpty) return 'Harga is required';
                        if (int.tryParse(s) == null)
                          return 'Harga must be a number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Qty'),
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        final n = int.tryParse(s);
                        if (n == null) return 'Qty must be a number';
                        if (n < 0) return 'Qty must be >= 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: ['NORMAL', 'WARNING', 'CRITICAL', 'DEAD STOCK']
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(controller.statusLabel(e))))
                          .toList(),
                      onChanged: (v) => setState(
                          () => selectedStatus = v ?? selectedStatus),
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;

                        controller.updateProduct(
                          product.id,
                          name: nameCtrl.text.trim(),
                          category: selectedCategory.toUpperCase(),
                          price: int.tryParse(priceCtrl.text.trim()) ?? 0,
                          qty: int.parse(qtyCtrl.text.trim()),
                          status: selectedStatus,
                          imagePath: controller.selectedImagePath.value,
                        );
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _sheetContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              )
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
