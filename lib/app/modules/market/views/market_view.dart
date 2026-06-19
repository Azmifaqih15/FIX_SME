import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/market_controller.dart';

class MarketView extends GetView<MarketController> {
  const MarketView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Market Insights", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SUMMARY CARDS ---
            Row(
              children: [
                _buildSummaryCard("Market Health", controller.marketHealth.value, Colors.green),
                const SizedBox(width: 12),
                _buildSummaryCard("Price Gaps", "${controller.priceGapsCount.value} Items", Colors.orange),
              ],
            ),
            const SizedBox(height: 25),

            const Text("T-Shirt Price Monitoring", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // --- LIST PRODUK MARKET ---
            Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.trackedProducts.length,
              itemBuilder: (context, index) {
                var product = controller.trackedProducts[index];
                return _buildMarketItem(product);
              },
            )),
            
            const SizedBox(height: 20),
            
            // ACTION BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.applyBulkAdjustments(),
                icon: const Icon(Icons.sync_alt),
                label: const Text("Sync All Prices to Market"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 5),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketItem(Map product) {
    bool hasGap = product['status'] == "Price Gap Detected";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasGap ? Colors.orange.withOpacity(0.5) : Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasGap ? Colors.orange[50] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(product['status'], 
                  style: TextStyle(fontSize: 10, color: hasGap ? Colors.orange : Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _priceColumn("Yours", product['shop_price'], isBold: true),
              _priceColumn("Modal", product['modal_price'], color: Colors.grey),
              _priceColumn("Shopee", product['shopee_price'] ?? "N/A"),
              _priceColumn("Tokopedia", product['tokopedia_price'] ?? "N/A"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceColumn(String label, String price, {bool isBold = false, Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(price, style: TextStyle(
          fontSize: 12, 
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color ?? Colors.black87
        )),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.grid_view_rounded, "Dashboard", 0),
          _navItem(Icons.inventory_2_outlined, "Inventory", 1),
          _navItem(Icons.qr_code_scanner_outlined, "Scan", 2),
          _navItem(Icons.analytics_rounded, "Market", 3, isActive: true),
          _navItem(Icons.person_outline, "Profile", 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, {bool isActive = false}) {
    return GestureDetector(
      onTap: () => controller.changePage(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF1E293B) : Colors.grey[400], size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: isActive ? const Color(0xFF1E293B) : Colors.grey[400])),
        ],
      ),
    );
  }
}