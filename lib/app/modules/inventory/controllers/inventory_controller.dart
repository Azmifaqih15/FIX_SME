import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_pages.dart';
import 'package:smart_sme_app/app/data/api_config.dart';

class Product {
  final int id;
  final String name;
  final String category;
  final int price;
  final int qty;
  final String status;
  final String image;
  final String sku;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.qty,
    required this.status,
    required this.image,
    this.sku = '',
  });

  Product copyWith({
    int? id,
    String? name,
    String? category,
    int? price,
    int? qty,
    String? status,
    String? image,
    String? sku,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      status: status ?? this.status,
      image: image ?? this.image,
      sku: sku ?? this.sku,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Tanpa Nama',
      category: json['category'] as String? ?? 'Tanpa Kategori',
      price: json['price'] as int? ?? 0,
      qty: json['qty'] as int? ?? 0,
      status: json['status'] as String? ?? 'NORMAL',
      image: json['image_url']?.toString() ?? json['image']?.toString() ?? "",
      sku: json['sku']?.toString() ?? json['barcode']?.toString() ?? "",
    );
  }
}

class InventoryController extends GetxController {
  final box = GetStorage();
  
  var selectedCategory = "All Items".obs;
  var productList = <Product>[].obs;
  var isLoading = true.obs;
  var userPhoto = ''.obs;

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
      ? productList
      : productList
          .where((p) =>
              p.category.toLowerCase() == selectedCategory.value.toLowerCase())
          .toList();

  final String baseUrl = '${ApiConfig.BASE_URL}/inventory';

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
    loadUserData();
    fetchInventory();
  }

  Future<void> loadUserData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final storedPhoto = box.read('user_photo');
    if (storedPhoto != null && storedPhoto is String && storedPhoto.isNotEmpty) {
      userPhoto.value = storedPhoto;
    }
    update(); // Paksa UI untuk render ulang
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

  void updateStockLocally(String sku, int quantityChange) {
    int index = productList.indexWhere((p) => p.sku == sku || p.name == sku || p.id.toString() == sku);
    if (index != -1) {
      var product = productList[index];
      int newQty = product.qty + quantityChange;
      if (newQty < 0) newQty = 0;
      
      // Ganti objek dengan yang baru menggunakan copyWith
      productList[index] = product.copyWith(qty: newQty);
    }
  }

  // --- API CALLS ---
  Future<void> fetchInventory({String query = ''}) async {
    isLoading.value = true;
    try {
      final urlString = query.isEmpty 
          ? '${ApiConfig.BASE_URL}/inventory/all'
          : '${ApiConfig.BASE_URL}/inventory/all?search=$query';
          
      ApiConfig.logNetwork(urlString);
      final response = await http.get(
        Uri.parse(urlString),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          final List<dynamic> data = decoded['data'];
          productList.assignAll(data.map((json) => Product.fromJson(json)).toList());
        } else if (decoded is List) {
          productList.assignAll(decoded.map((json) => Product.fromJson(json)).toList());
        }
      }
    } catch (e) {
      print('Error fetching inventory: $e');
    } finally {
      isLoading.value = false;
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
      ApiConfig.logNetwork(baseUrl);
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
          "image": imagePath.trim().isNotEmpty ? imagePath.trim() : "",
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchInventory();
      }
    } catch (e) {
      print('Error creating product: $e');
    }
  }

  Future<void> updateProduct(
    int id, {
    required String name,
    required String category,
    required int price,
    required int qty,
    required String status,
    String? imagePath, // Diubah agar konsisten
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      ApiConfig.logNetwork('$baseUrl/$id');
      
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/$id'));
      request.headers['ngrok-skip-browser-warning'] = 'true';
      request.fields['name'] = name;
      request.fields['category'] = category;
      request.fields['price'] = price.toString();
      request.fields['qty'] = qty.toString();
      request.fields['status'] = status;
      if (userId != null) request.fields['user_id'] = userId;

      if (imagePath != null && imagePath.trim().isNotEmpty && !imagePath.startsWith('http')) {
        request.files.add(await http.MultipartFile.fromPath('product_image', imagePath));
      }
      
      var response = await request.send();
      if (response.statusCode == 200) {
        await fetchInventory();
      } else {
        print('Error updating product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      ApiConfig.logNetwork('$baseUrl/$id');
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (response.statusCode == 200) {
        await fetchInventory();
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
