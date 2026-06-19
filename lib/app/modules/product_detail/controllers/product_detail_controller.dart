import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  // Data Produk (Bisa diisi dari argument saat navigasi atau API)
  var productName = "Premium Lavender Organic Soap".obs;
  var productDesc =
      "Hand-milled with essential oils and organic shea butter. Sustainably sourced and packaged."
          .obs;
  var price = "\$12.50".obs;
  var currentStock = 432.obs;
  var salesVelocity = "12 units/day avg.".obs;

  // Data AI Forecast & Rekomendasi
  var stockoutDate = "Nov 14, 2026".obs; // Disesuaikan dengan tahun proyek
  var restockWindow = "Oct 28 - Nov 2".obs;
  var recommendation =
      "Based on current Sales Velocity and lead times for Organic Soap base, we recommend placing a restock order of 800 units before Friday. This will ensure 98% service level through the upcoming holiday promotion."
          .obs;

  void generatePurchaseOrder() {
    Get.snackbar(
      "Purchase Order Generated",
      "PO for 800 units has been created and sent to supplier.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void editProduct() {
    print("Edit Product Clicked");
  }

  void manualAdjustment() {
    print("Manual Adjustment Clicked");
  }

  void viewMarketTrends() {
    print("View Market Trends Clicked");
  }
}
