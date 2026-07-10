import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/fashion_controller.dart';

class FashionView extends GetView<FashionController> {
  const FashionView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Fashion / Inventory'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchData,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (controller.fashionList.isEmpty) {
          return const Center(child: Text('Belum ada produk di database.'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.fetchData();
          },
          child: ListView.builder(
            itemCount: controller.fashionList.length,
            itemBuilder: (context, index) {
              final product = controller.fashionList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                child: ListTile(
                  leading: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? Image.network(
                          product.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.inventory_2),
                        ),
                  title: Text(
                    product.name ?? 'Produk Tanpa Nama',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SKU: ${product.sku ?? '-'} | Kategori: ${product.category ?? '-'}'),
                      Text('Warna: ${product.color ?? '-'} | Size: ${product.size ?? '-'}'),
                      Text('Stok: ${product.qty ?? 0}'),
                    ],
                  ),
                  trailing: Text(
                    product.price != null 
                        ? 'Rp ${product.price}' 
                        : '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16, 
                      color: Colors.green
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
