import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/business_info_controller.dart';

class BusinessInfoView extends GetView<BusinessInfoController> {
  const BusinessInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Business Information",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Store Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111E38),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Manage your store profile and contact information.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              _buildTextField(
                controller: controller.storeNameCtrl,
                label: "Store Name",
                icon: Icons.storefront_rounded,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: controller.categoryCtrl,
                label: "Business Category",
                icon: Icons.category_outlined,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: controller.phoneCtrl,
                label: "Phone Number",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: controller.addressCtrl,
                label: "Store Address",
                icon: Icons.location_on_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              const Text(
                "Warehouse Location",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111E38),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: controller.warehouseCtrl,
                label: "Warehouse Name / Address",
                icon: Icons.warehouse_outlined,
              ),
              const SizedBox(height: 40),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111E38),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk membuat form input agar kode tidak berulang
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint:
            maxLines > 1, // Agar label tetap di atas jika multiline
        prefixIcon: Padding(
          padding:
              EdgeInsets.only(bottom: maxLines > 1 ? (maxLines * 12.0) : 0),
          child: Icon(icon, color: const Color(0xFF64748B)),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
        ),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'This field is required' : null,
    );
  }
}
