import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/monthly_recap_controller.dart';

class MonthlyRecapView extends StatelessWidget {
  const MonthlyRecapView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller langsung di View karena kita navigasi menggunakan Get.to()
    final controller = Get.put(MonthlyRecapController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Rekap Bulanan',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Laporan Performa",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildRecapCard(
                    "Total Profit",
                    Obx(() => controller.isLoading.value 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                                .format(controller.totalProfit.value),
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                          )),
                    Icons.trending_up,
                    Colors.green,
                  ),
                  _buildRecapCard(
                    "Kategori Terlaris",
                    Obx(() => controller.isLoading.value 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            controller.bestCategory.value,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                    Icons.star_rounded,
                    Colors.orangeAccent,
                  ),
                  _buildRecapCard(
                    "Low Stock",
                    Obx(() => controller.isLoading.value 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            controller.lowStock.value.toString(),
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 24),
                          )),
                    Icons.warning_amber_rounded,
                    Colors.orange,
                  ),
                  _buildRecapCard(
                    "Dead Stock",
                    Obx(() => controller.isLoading.value 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            controller.deadStockCount.value.toString(),
                            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 24),
                          )),
                    Icons.inventory_2_rounded,
                    Colors.grey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Daftar Dead Stock (Tidak terjual > 30 hari)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.deadStockList.isEmpty) {
                  return const Center(
                    child: Text("Tidak ada produk dead stock.", style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                  itemCount: controller.deadStockList.length,
                  itemBuilder: (context, index) {
                    final item = controller.deadStockList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text("SKU: ${item.sku}"),
                        trailing: Text("Sisa: ${item.qty}", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecapCard(String title, Widget valueWidget, IconData icon, Color iconColor) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            valueWidget,
          ],
        ),
      ),
    );
  }
}
