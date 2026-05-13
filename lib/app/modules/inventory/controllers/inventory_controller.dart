import 'package:get/get.dart';
import '../../../routes/app_pages.dart'; 

class InventoryController extends GetxController {
  // --- STATE MANAGEMENT ---
  var selectedCategory = "All Items".obs;
  var categories = ["All Items", "Personal Care", "Electronics", "Accessories"];

  var products = [
    {
      "name": "Organic Soap",
      "category": "PERSONAL CARE",
      "qty": 120,
      "status": "NORMAL",
      "image": "https://images.unsplash.com/photo-1600857062241-98e5dba7f214?q=80&w=500"
    },
    {
      "name": "Hand Sanitizer",
      "category": "HEALTHCARE",
      "qty": 5,
      "status": "CRITICAL",
      "image": "https://images.unsplash.com/photo-1584622781564-1d9876a13d00?q=80&w=500"
    },
    {
      "name": "Old Model Case",
      "category": "ACCESSORIES",
      "qty": 50,
      "status": "DEAD STOCK",
      "image": "https://images.unsplash.com/photo-1541807084-5c52b6b3adef?q=80&w=500"
    },
    {
      "name": "Pro Smart Watch",
      "category": "ELECTRONICS",
      "qty": 10,
      "status": "WARNING",
      "image": "https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=500"
    },
  ].obs;

  // --- FUNGSI NAVIGASI OTOMATIS ---
  // Fungsi ini WAJIB ada agar onTap di View bisa jalan
  void changePage(int index) {
    if (index == 1) return; // Index 1 adalah Inventory, jika diklik saat di sini, tidak perlu pindah.

    switch (index) {
      case 0:
        Get.offAllNamed(Routes.DASHBOARD);
        break;
      case 1:
        Get.offAllNamed(Routes.INVENTORY);
        break;
      case 2:
        Get.offAllNamed(Routes.SCAN);
        break;
      case 3:
        Get.offAllNamed(Routes.MARKET);
        break;
      case 4:
        Get.offAllNamed(Routes.PROFILE);
        break;
    }
  }
}