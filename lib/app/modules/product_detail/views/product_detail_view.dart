import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_detail_controller.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color.fromARGB(255, 64, 129, 240); // Sesuai tema
    const Color bgColor =
        Color(0xFFF8FAFC); // Latar belakang kebiruan super terang

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Inventory AI",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {}),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 14,
              backgroundImage:
                  NetworkImage("https://i.pravatar.cc/100"), // Avatar dummy
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PRODUCT IMAGE ---
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                "https://images.unsplash.com/photo-1600857062241-98e5dba7f214?q=80&w=600&auto=format&fit=crop", // Ganti asset lokal nantinya
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // --- TAGS ---
            Row(
              children: [
                _buildTag("Organic Certified", Colors.blue[50]!,
                    Colors.blue[700]!, Icons.verified_outlined),
                const SizedBox(width: 8),
                _buildTag(
                    "In Stock", Colors.green[50]!, Colors.green[700]!, null),
              ],
            ),
            const SizedBox(height: 16),

            // --- TITLE & DESC ---
            Obx(() => Text(controller.productName.value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Obx(() => Text(
                  controller.productDesc.value,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey[700], height: 1.4),
                )),
            const SizedBox(height: 20),

            // --- PRICE & STOCK GRID ---
            Row(
              children: [
                Expanded(
                    child: _buildInfoCard(
                        "Price", "${controller.price.value} / unit")),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildInfoCard("Current Stock",
                        "${controller.currentStock.value} Units",
                        borderLeft: true)),
              ],
            ),
            const SizedBox(height: 16),

            // --- SALES VELOCITY ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  // Dot indikator biru
                  Row(
                    children: [
                      _buildDot(Colors.cyan),
                      _buildDot(Colors.cyan[200]!),
                      _buildDot(Colors.cyan[100]!),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Obx(() => Text(
                      "High Sales Velocity: ${controller.salesVelocity.value}",
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600))),
                  const Spacer(),
                  const Icon(Icons.trending_up, color: Colors.teal, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- AI STOCK FORECAST (Fitur Capstone) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple[100]!),
                boxShadow: [
                  BoxShadow(
                      color: Colors.purple.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: Colors.purple[400], size: 18),
                          const SizedBox(width: 8),
                          const Text("AI Stock Forecast",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("STOCKOUT ALERT",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10)),
                          Obx(() => Text(controller.stockoutDate.value,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14))),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Predicted depletion based on historical seasonality.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 16),

                  // Mockup Grafik (Placeholder)
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.purple[50]?.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5)
                            ]),
                        child: Obx(() => Text(
                            "Next restock window:\n${controller.restockWindow.value}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.indigo))),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- MARKET TRENDS ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bar_chart, color: Colors.teal),
                      SizedBox(width: 8),
                      Text("Market Trends",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Organic personal care demand is up 14% this quarter.",
                      style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: controller.viewMarketTrends,
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.blue[50],
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("View Trends",
                              style: TextStyle(color: Colors.indigo)),
                          SizedBox(width: 8),
                          Icon(Icons.open_in_new,
                              size: 14, color: Colors.indigo),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- INTELLIGENT RECOMMENDATION ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text("Intelligent Recommendation",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.indigo)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Text(
                        controller.recommendation.value,
                        style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 13,
                            height: 1.5),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- ACTION BUTTONS ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.editProduct,
                    icon:
                        const Icon(Icons.edit, size: 16, color: Colors.black87),
                    label: const Text("Edit Product",
                        style: TextStyle(color: Colors.black87)),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.manualAdjustment,
                    icon: const Icon(Icons.settings,
                        size: 16, color: Colors.black87),
                    label: const Text("Manual Adjust",
                        style: TextStyle(color: Colors.black87)),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // GENERATE PO BUTTON (Gradient)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(colors: [
                  Color(0xFF00C6FF),
                  Color(0xFF0072FF)
                ]), // Cyan to Blue gradient
                boxShadow: [
                  BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: controller.generatePurchaseOrder,
                icon: const Icon(Icons.sync, color: Colors.white),
                label: const Text("Generate Purchase Order",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildTag(
      String text, Color bgColor, Color textColor, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4)
          ],
          Text(text,
              style: TextStyle(
                  color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, {bool borderLeft = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          if (borderLeft)
            Container(
                width: 3,
                height: 30,
                decoration: BoxDecoration(
                    color: Colors.teal[800],
                    borderRadius: BorderRadius.circular(2))),
          if (borderLeft) const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Align(
      widthFactor:
          0.6, // Menggantikan margin negatif untuk membuat efek saling menumpuk (overlap)
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}
