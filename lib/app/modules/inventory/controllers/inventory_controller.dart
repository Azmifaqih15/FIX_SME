import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../routes/app_pages.dart';

class Product {
  final int id;
  final String name;
  final String category;
  final int qty;
  final String status;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.qty,
    required this.status,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      qty: json['qty'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      image: json['image'] as String? ??
          "https://images.unsplash.com/photo-1520975958225-61b2f8c6c6b4?q=80&w=500",
    );
  }
}

class InventoryController extends GetxController {
  var selectedCategory = "All Items".obs;
  var allProducts = <Product>[].obs;

  // Variabel untuk menampung path gambar lokal
  var selectedImagePath = ''.obs;

  final ImagePicker _picker = ImagePicker();

  // --- FUNGSI IMAGE PICKER ---
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil gambar: $e");
    }
  }

  void resetImage() {
    selectedImagePath.value = '';
  }

  List<Product> get filteredProducts => selectedCategory.value == 'All Items'
      ? allProducts
      : allProducts
          .where((p) =>
              p.category.toLowerCase() == selectedCategory.value.toLowerCase())
          .toList();

  final String baseUrl =
      'https://braden-noncrusading-uncarnivorously.ngrok-free.dev/api/v1/products';

  var categories = [
    "All Items",
    "Oversize",
    "Boxy Fit",
    "Regular Fit",
    "Fitted"
  ];

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  String statusLabel(String? raw) {
    switch (raw) {
      case 'NORMAL':
        return 'Normal';
      case 'WARNING':
        return 'Warning';
      case 'CRITICAL':
        return 'Critical';
      case 'DEAD STOCK':
        return 'Dead Stock';
      default:
        return raw ?? '';
    }
  }

  // --- API CALLS ---
  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        allProducts.value = data.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> addProduct({
    required String name,
    required String category,
    required int qty,
    required String status,
    required String imagePath, // Menerima path lokal dari UI
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
        body: json.encode({
          "name": name,
          "category": category,
          "qty": qty,
          "status": status,
          // PERBAIKAN: Menggunakan variabel imagePath, bukan image
          "image": imagePath.trim().isNotEmpty
              ? imagePath.trim()
              : "https://images.unsplash.com/photo-1520975958225-61b2f8c6c6b4?q=80&w=500",
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchProducts();
      }
    } catch (e) {
      print('Error creating product: $e');
    }
  }

  Future<void> updateProduct(
    int id, {
    required String name,
    required String category,
    required int qty,
    required String status,
    String? imagePath, // Diubah agar konsisten
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
        body: json.encode({
          "name": name,
          "category": category,
          "qty": qty,
          "status": status,
          // PERBAIKAN: Menggunakan variabel imagePath
          "image": imagePath?.trim().isNotEmpty == true
              ? imagePath!.trim()
              : "https://images.unsplash.com/photo-1520975958225-61b2f8c6c6b4?q=80&w=500",
        }),
      );
      if (response.statusCode == 200) {
        await fetchProducts();
      }
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (response.statusCode == 200) {
        await fetchProducts();
      }
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  void changePage(int index) {
    switch (index) {
      case 0:
        Get.offAllNamed(Routes.DASHBOARD);
        break;
      case 1:
        break; // Stay here
      case 2:
        Get.toNamed(Routes.SCAN);
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
