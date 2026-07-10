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
        title: const Text("T-Shirt Price Monitoring", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
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
                Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchMarketData,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (controller.monitoringList.isEmpty) {
          return const Center(
            child: Text('Belum ada data analisis pasar', style: TextStyle(fontSize: 16, color: Colors.grey)),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchMarketData,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
            itemCount: controller.monitoringList.length,
            itemBuilder: (context, index) {
              final data = controller.monitoringList[index];
              return _buildMonitorCard(data);
            },
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMonitorCard(PriceMonitorModel data) {
    bool isGapDetected = data.statusPersaingan == 'KURANG KOMPETITIF' || data.statusPersaingan == 'PRICE GAP';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGapDetected ? Colors.orange : Colors.grey.shade300,
          width: isGapDetected ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.kategori,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _buildBadge(data.statusPersaingan),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          ),
          // Bottom Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('Yours', data.hargaJualSaatIni.toDouble()),
              _buildInfoColumn('Modal', data.hppInternal.toDouble(), isModal: true),
              _buildInfoColumn('Rata2', data.rataRataPasar),
              _buildInfoColumn('Saran', data.rekomendasiHargaJual),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'SANGAT KOMPETITIF':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case 'KURANG KOMPETITIF':
      case 'PRICE GAP':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case 'DEAD STOCK':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30), 
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatK(double price) {
    if (price <= 0) return '?';
    int kValue = (price / 1000).round();
    return 'Rp ${kValue}k';
  }

  Widget _buildInfoColumn(String label, double price, {bool isModal = false}) {
    String priceText = _formatK(price);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          priceText,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isModal ? Colors.grey.shade600 : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
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
