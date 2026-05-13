import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scan_controller.dart';

class ScanView extends GetView<ScanController> {
  const ScanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Inventory AI', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.black))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- CAMERA VIEW PLACEHOLDER ---
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/400x250/000000/FFFFFF?text=Camera+Active'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Container(
                  width: 200,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- STOCK ACTION BUTTONS ---
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: "Stock In",
                    icon: Icons.add_circle_outline,
                    color: Colors.green[50]!,
                    iconColor: Colors.green,
                    onTap: controller.onStockIn,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildActionButton(
                    label: "Stock Out",
                    icon: Icons.remove_circle_outline,
                    color: Colors.red[50]!,
                    iconColor: Colors.red,
                    onTap: controller.onStockOut,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- MANUAL ENTRY ---
            const Align(alignment: Alignment.centerLeft, child: Text("Manual Entry", style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: "Search by Name or SKU",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),

            // --- RECENT SCANS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recent Scans", style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text("View All")),
              ],
            ),
            Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentScans.length,
              itemBuilder: (context, index) {
                var item = controller.recentScans[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.inventory_2_outlined),
                  ),
                  title: Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(item['sku'] as String, style: const TextStyle(fontSize: 12)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(item['qty'] as String, style: TextStyle(color: item['color'] as Color, fontWeight: FontWeight.bold)),
                      Text(item['time'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                );
              },
            )),
            const SizedBox(height: 100),
          ],
        ),
      ),

      // --- BOTTOM NAVIGATION BAR DENGAN SHADOW ---
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.grid_view_rounded, "Dashboard", onTap: () => controller.changePage(0)),
            _buildBottomNavItem(Icons.inventory_2_outlined, "Inventory", onTap: () => controller.changePage(1)),
            _buildBottomNavItem(Icons.qr_code_scanner_outlined, "Scan", isActive: true, onTap: () => controller.changePage(2)),
            _buildBottomNavItem(Icons.analytics_outlined, "Market", onTap: () => controller.changePage(3)),
            _buildBottomNavItem(Icons.person_outline, "Profile", onTap: () => controller.changePage(4)),
          ],
        ),
      ),
    );
  }

  // --- HELPER UNTUK ITEM NAVIGASI ---
  Widget _buildBottomNavItem(IconData icon, String label, {bool isActive = false, VoidCallback? onTap}) {
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
            Icon(icon, color: isActive ? const Color(0xFF1E293B) : Colors.grey[400], size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              fontSize: 10,
              color: isActive ? const Color(0xFF1E293B) : Colors.grey[400],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required Color iconColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(height: 5),
            Text(label, style: TextStyle(color: iconColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}