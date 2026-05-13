import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/inventory_controller.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
              backgroundImage:
                  NetworkImage('https://i.pravatar.cc/150?img=11')),
        ),
        title: const Text("Inventory AI",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {})
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SEARCH BAR ---
            TextField(
              decoration: InputDecoration(
                hintText: "Search Inventory...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),

            // --- CATEGORIES TABS ---
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
                            color: isSelected ? Colors.black : Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Text(controller.categories[index],
                            style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // --- AI STOCK FORECAST BANNER ---
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                    left: BorderSide(color: Color(0xFF3B82F6), width: 4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: Color(0xFF3B82F6), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("AI Stock Forecast",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(
                            "System predicts high demand for 'Organic Soap' next week. Consider increasing stock by 20%.",
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- PRODUCT GRID ---
            Obx(() => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    var product = controller.products[index];
                    return _buildProductCard(product);
                  },
                )),
            const SizedBox(height: 100),
          ],
        ),
      ),

      // --- BOTTOM NAVIGATION BAR DENGAN EFEK SHADOW & AUTO-NAVIGATE ---
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, -5), // Shadow halus ke arah atas
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.grid_view_rounded, "Dashboard", 
                onTap: () => controller.changePage(0)),
            _buildBottomNavItem(Icons.inventory_2_outlined, "Inventory", 
                isActive: true, onTap: () => controller.changePage(1)),
            _buildBottomNavItem(Icons.qr_code_scanner_outlined, "Scan", 
                onTap: () => controller.changePage(2)),
            _buildBottomNavItem(Icons.analytics_outlined, "Market", 
                onTap: () => controller.changePage(3)),
            _buildBottomNavItem(Icons.person_outline, "Profile", 
                onTap: () => controller.changePage(4)),
          ],
        ),
      ),
    );
  }

  // --- HELPER UNTUK ITEM NAVIGASI ---
  Widget _buildBottomNavItem(IconData icon, String label,
      {bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF1F5F9) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF1E293B) : Colors.grey[400],
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? const Color(0xFF1E293B) : Colors.grey[400],
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map product) {
    Color statusColor;
    switch (product['status']) {
      case 'CRITICAL': statusColor = Colors.red; break;
      case 'DEAD STOCK': statusColor = Colors.blueGrey; break;
      case 'WARNING': statusColor = Colors.orange; break;
      default: statusColor = const Color(0xFF10B981);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(product['image'], fit: BoxFit.cover, width: double.infinity),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(4)),
                    child: Text(product['status'], style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['category'], style: TextStyle(color: Colors.grey[500], fontSize: 9, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Qty: ${product['qty']}", style: TextStyle(color: product['qty'] < 10 ? Colors.red : Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                    const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}