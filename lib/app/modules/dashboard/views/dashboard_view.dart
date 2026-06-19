import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(10.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
          ),
        ),
        title: const Text("Inventory AI",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {
                Get.toNamed(Routes.NOTIFICATION);
              }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text("Selamat Datang, ${controller.userName.value}",
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B)))),
            const SizedBox(height: 4),
            Text(
                "Infrastructure oversight is active. 2 critical alerts require attention.",
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            const SizedBox(height: 25),

            // --- STATS GRID ---
            Obx(() => GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                  children: [
                    _buildStatCard("Total Items", controller.totalItems.value,
                        Colors.black),
                    _buildStatCard("Low Stock",
                        controller.lowStock.value.toString(), Colors.red,
                        isValueRed: true),
                    _buildStatCard("Dead Stock",
                        controller.deadStock.value.toString(), Colors.black),
                    _buildStatCard(
                        "Potential Profit",
                        controller.potentialProfit.value,
                        const Color(0xFF0D9488)),
                  ],
                )),

            const SizedBox(height: 25),
            const Row(children: [
              Icon(Icons.auto_awesome, color: Color(0xFF6366F1), size: 18),
              SizedBox(width: 8),
              Text("AI Insights",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),

            _buildAIInsightCard(
              icon: Icons.assignment_outlined,
              title: "Predictive Restock Alert",
              desc: "3 items need restocking soon.",
              btnText: "Order Now",
            ),
            _buildAIInsightCard(
              icon: Icons.not_interested_outlined,
              title: "Dead Stock Detected",
              desc: "2 items haven't moved in 30 days.",
              btnText: "View Items",
            ),
            const SizedBox(
                height: 30), // Padding bawah agar konten tidak terpotong
          ],
        ),
      ),

      // --- BOTTOM NAVIGATION DENGAN EFEK SHADOW & AUTO-NAVIGATE ---
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
            _buildBottomNavItem(Icons.grid_view_rounded, "Dashboard",
                isActive: true, onTap: () => controller.changePage(0)),
            _buildBottomNavItem(Icons.inventory_2_outlined, "Inventory",
                onTap: () => controller.changePage(1)),
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

  // --- HELPERS ---
  Widget _buildStatCard(String title, String value, Color color,
      {bool isValueRed = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[100]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isValueRed ? Colors.red : color)),
        ],
      ),
    );
  }

  Widget _buildAIInsightCard(
      {required IconData icon,
      required String title,
      required String desc,
      required String btnText}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[100]!)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[200]!),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(btnText,
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold))),
                    ]),
                const SizedBox(height: 8),
                Text(desc,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[600], height: 1.4)),
              ])),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label,
      {bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF1F5F9) : Colors.transparent,
            borderRadius: BorderRadius.circular(12)),
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
                        isActive ? const Color(0xFF1E293B) : Colors.grey[400],
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
