import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/market_controller.dart';

class MarketView extends GetView<MarketController> {
  const MarketView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF3F51B5); 
    const Color scaffoldBg = Color(0xFFF8F9FB);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
          ),
        ),
        title: const Text("Market Insight", 
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildHeaderStat("Market Health", "Stable", "+2.4% vs last week", Colors.teal)),
                const SizedBox(width: 12),
                Expanded(child: _buildHeaderStat("Price Gaps", "12", "Detected", Colors.red, isAlert: true)),
              ],
            ),
            const SizedBox(height: 20),
            _buildAIRecommendationCard(primaryColor),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tracked Products", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text("See All")),
              ],
            ),
            const SizedBox(height: 10),
            Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.trackedProducts.length,
              itemBuilder: (context, index) {
                return _buildProductItem(controller.trackedProducts[index]);
              },
            )),
            const SizedBox(height: 100),
          ],
        ),
      ),
      
      // --- BOTTOM NAVIGATION DENGAN SHADOW & AUTO-NAVIGATE ---
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, -5), // Shadow ke arah atas
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.grid_view_rounded, "Dashboard", onTap: () => controller.changePage(0)),
            _buildBottomNavItem(Icons.inventory_2_outlined, "Inventory", onTap: () => controller.changePage(1)),
            _buildBottomNavItem(Icons.qr_code_scanner_outlined, "Scan", onTap: () => controller.changePage(2)),
            _buildBottomNavItem(Icons.analytics_outlined, "Market", isActive: true, onTap: () => controller.changePage(3)),
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

  // (Tetap simpan widget helper lain seperti _buildHeaderStat, _buildAIRecommendationCard, dll di sini)
  Widget _buildHeaderStat(String label, String val, String sub, Color color, {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 5),
          Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Row(children: [
            if (isAlert) Icon(Icons.warning_amber_rounded, size: 12, color: color),
            Text(sub, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          ]),
        ],
      ),
    );
  }

  Widget _buildAIRecommendationCard(Color btnColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, colors: [Colors.blue[50]!, Colors.white]),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.auto_awesome, color: Colors.blue[700], size: 18),
            const SizedBox(width: 8),
            const Text("AI RECOMMENDATION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1A237E))),
          ]),
          const SizedBox(height: 10),
          const Text("We detected a 15% price gap on Electronics. Market prices on Shopee have trended upwards.", style: TextStyle(fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.applyBulkAdjustments(),
              style: ElevatedButton.styleFrom(backgroundColor: btnColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text("Apply Bulk Adjustments", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProductItem(Map item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        children: [
          Row(
            children: [
              Container(height: 50, width: 50, color: Colors.grey[200], child: const Icon(Icons.image_outlined)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Shop: ${item['shop_price']}  Modal: ${item['modal_price']}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ]),
              ),
              _buildBadge(item['status']),
            ],
          ),
          const Divider(height: 25),
          Row(
            children: [
              _marketTag("S", item['shopee_price'] ?? '-', Colors.orange),
              const SizedBox(width: 15),
              _marketTag("T", item['tokopedia_price'] ?? '-', Colors.green),
              const Spacer(),
              const Text("Match Market", style: TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    bool isGreen = text == "Competitive";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: isGreen ? Colors.green[50] : Colors.red[50], borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: isGreen ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _marketTag(String label, String price, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 8, backgroundColor: color, child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 8))),
        const SizedBox(width: 5),
        Text(price, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}