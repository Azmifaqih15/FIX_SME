import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../routes/app_pages.dart';
import '../controllers/dashboard_controller.dart';
import '../../notification/controllers/notification_controller.dart'
    as import_notif;

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Obx(() => CircleAvatar(
                backgroundColor: const Color(0xFF1E293B),
                backgroundImage: controller.userPhoto.value.isNotEmpty
                    ? NetworkImage(controller.userPhoto.value)
                    : null,
                child: controller.userPhoto.value.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              )),
        ),
        title: const Text("Inventory AI",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        actions: [
          // Inject NotificationController langsung di view agar bisa diakses
          Builder(
            builder: (context) {
              final notifController =
                  Get.put(import_notif.NotificationController());
              return Obx(() {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none,
                          color: Colors.black),
                      onPressed: () {
                        notifController.fetchNotifications();
                        notifController.showNotificationSheet();
                      },
                    ),
                    if (notifController.notifications.isNotEmpty)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 10,
                            minHeight: 10,
                          ),
                        ),
                      ),
                  ],
                );
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STATS GRID ---
            Obx(() => GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                  children: [
                    _buildStatCard("Total Items",
                        controller.totalItems.value.toString(), Colors.black),
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

            _buildRecommendationSection(),

            const SizedBox(height: 25),

            _buildStockChart(),

            const SizedBox(height: 25),

            _buildLineChartSection(),

            const SizedBox(height: 30),

            _buildBarChartSection(),

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

  //HELPERS

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

  // 🟢 KODE BARU: SECTION REKOMENDASI DARI MONGODB
  Widget _buildRecommendationSection() {
    return Obx(() {
      if (controller.isLoadingRecommendation.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.recommendationData.isEmpty) {
        return const SizedBox.shrink(); // Sembunyikan jika kosong
      }

      var data = controller.recommendationData;
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF), // Biru muda cerah
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AI Rekomendasi: ${data['kategori'] ?? '-'}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Harga pasar yang disarankan: Rp ${data['rekomendasi_harga'] ?? 0}",
                    style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Status: ${data['status'] ?? '-'}",
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStockChart() {
    // Definisi warna per kategori agar konsisten
    final Map<String, Color> categoryColors = {
      'Oversize': const Color(0xFF10B981),
      'Boxy Fit': const Color(0xFFF59E0B),
      'Fitted': const Color(0xFFDC2626),
      'Regular Fit': const Color(0xFF6B7280),
      'Lainnya': Colors.purple,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ringkasan Stok Berdasarkan Kategori Fitting",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Obx(() {
              if (controller.dynamicGrandTotal == 0) {
                return PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: controller.dynamicPieChartSections,
                  ),
                );
              }

              return PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: controller.dynamicPieChartSections,
                ),
                swapAnimationDuration: const Duration(milliseconds: 800),
                swapAnimationCurve: Curves.easeInOut,
              );
            }),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.dynamicGrandTotal == 0) return const SizedBox();
            
            // Generate Legend secara dinamis berdasarkan kategori yang ada
            List<Widget> legends = [];
            final Map<String, Color> categoryColors = {
              'Oversize': const Color(0xFF10B981),
              'Boxy Fit': const Color(0xFFF59E0B),
              'Fitted': const Color(0xFFDC2626),
              'Regular Fit': const Color(0xFF6B7280),
              'Lainnya': Colors.purple,
            };
            
            Map<String, int> tempTotals = {};
            for (var item in controller.inventoryController.productList) {
               tempTotals[item.category] = (tempTotals[item.category] ?? 0) + item.qty;
            }
            
            tempTotals.forEach((category, stock) {
               if (stock > 0) {
                 Color color = categoryColors[category] ?? Colors.grey;
                 legends.add(_buildLegend(color, category));
               }
            });
            
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: legends,
            );
          }),
          Obx(() {
            if (controller.totalInventory.value == 0) return const SizedBox();
            
            double progress = controller.totalInventory.value / 10000;
            if (progress > 1.0) progress = 1.0;
            
            Color progressColor = Colors.green;
            if (progress > 0.8) progressColor = Colors.red;
            else if (progress > 0.5) progressColor = Colors.orange;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text("Kapasitas Gudang: ${controller.totalInventory.value.toInt()} / 10.000", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11, color: Colors.black87)),
      ],
    );
  }

  Widget _buildBarChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Performa Penjualan (12 Bulan)",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 24),
          
          Obx(() {
            List<String> months = [
              'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
              'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
            ];

            return Column(
              children: [
                // AREA GRAFIK ATAU PESAN KOSONG
                if (!controller.hasProfitData)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.insert_chart_outlined, size: 48, color: Colors.blue[300]),
                        const SizedBox(height: 16),
                        const Text(
                          "Belum ada data profit.",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Lakukan Scan Out untuk mulai mencatat!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        // Sesuaikan lebar agar chart tidak berdesakan saat mode 'All'
                        width: controller.selectedMonth.value == 'All' ? 600 : Get.width - 80,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 30, // Max Y ini nantinya bisa dibuat dinamis sesuai data
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const style = TextStyle(color: Colors.grey, fontSize: 10);
                                    var displayMonths = controller.monthLabels.isEmpty ? months : controller.monthLabels;
                                    
                                    if (controller.selectedMonth.value == 'All') {
                                      if (value.toInt() >= 0 && value.toInt() < displayMonths.length) {
                                        return Text(displayMonths[value.toInt()], style: style);
                                      }
                                    } else {
                                      // Hanya satu batang yang tampil, label mengikuti bulan yang dipilih
                                      if (value.toInt() == 0) {
                                        return Text(controller.selectedMonth.value, style: style);
                                      }
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) => Text(
                                      controller.formatProfit(value),
                                      style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barTouchData: BarTouchData(
                              touchCallback: (FlTouchEvent event, barTouchResponse) {
                                if (event is FlTapUpEvent && barTouchResponse != null && barTouchResponse.spot != null) {
                                  int index = barTouchResponse.spot!.touchedBarGroupIndex;
                                  
                                  int actualMonthIndex = index;
                                  if (controller.selectedMonth.value != 'All') {
                                    // Jika sedang filter, indeks 0 mewakili bulan yang dipilih
                                    actualMonthIndex = months.indexOf(controller.selectedMonth.value);
                                  }
                                  
                                  controller.selectedMonthIndex.value = actualMonthIndex;
                                  var detailData = controller.getDetailPerMonth(actualMonthIndex);
                                  _showMonthDetailBottomSheet(detailData);
                                }
                              },
                            ),
                            barGroups: controller.selectedMonth.value == 'All'
                                ? List.generate(
                                    controller.monthlyProfits.length,
                                    (index) => _makeBarGroup(
                                      index, 
                                      controller.monthlyProfits[index], 
                                      index == controller.selectedMonthIndex.value
                                    ),
                                  )
                                : [
                                    _makeBarGroup(
                                      0, // Selalu di koordinat X=0 untuk single bar
                                      controller.monthlyProfits[months.indexOf(controller.selectedMonth.value)],
                                      months.indexOf(controller.selectedMonth.value) == controller.selectedMonthIndex.value
                                    )
                                  ],
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
                
                // AREA FILTER
                _buildMonthFilter(months),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMonthFilter(List<String> months) {
    List<String> filterOptions = ['All', ...months];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterOptions.map((option) {
          bool isSelected = controller.selectedMonth.value == option;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) {
                  controller.selectedMonth.value = option;
                  controller.selectedMonthIndex.value = -1;
                  
                  if (option != 'All') {
                    // Tampilkan detail via bottomSheet
                    int monthIndex = months.indexOf(option);
                    var detailData = controller.getDetailPerMonth(monthIndex);
                    _showMonthDetailBottomSheet(detailData);
                  }
                }
              },
              selectedColor: const Color(0xFF4F46E5),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[300]!,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

// Helper untuk membuat batang grafik
  BarChartGroupData _makeBarGroup(int x, double y, bool isSelected) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: y,
        color: isSelected ? const Color(0xFF312E81) : const Color(0xFF4F46E5), // Lebih gelap jika dipilih
        width: 15,
        borderRadius: BorderRadius.circular(4),
      ),
    ]);
  }

  // BottomSheet untuk menampilkan detail transaksi per bulan
  void _showMonthDetailBottomSheet(Map<String, dynamic> data) {
    String monthName = data['month_name'];
    double totalProfit = data['total_profit'];
    List<Map<String, dynamic>> transactions = data['transactions'];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              "Detail Transaksi - $monthName",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Total Profit: ${controller.formatRupiah((totalProfit * 1000000).toInt())}",
              style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            if (transactions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        "Belum ada transaksi di bulan ini",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    var tx = transactions[index];
                    DateTime date = DateTime.parse(tx['createdAt']);
                    String formattedDate = "${date.day}-${date.month}-${date.year}";
                    
                    double profitVal = 0.0;
                    if (tx.containsKey('potentialProfit')) {
                      profitVal = (tx['potentialProfit'] as num).toDouble();
                    } else if (tx.containsKey('profit')) {
                      profitVal = (tx['profit'] as num).toDouble();
                    }

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFEFF6FF),
                        child: Icon(Icons.attach_money, color: Colors.blueAccent, size: 18),
                      ),
                      title: const Text("Profit Transaksi", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text(formattedDate, style: const TextStyle(fontSize: 11)),
                      trailing: Text(
                        "+${controller.formatRupiah((profitVal * 1000000).toInt())}",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      isScrollControlled: true, // Agar list view bisa di-scroll jika datanya banyak
    );
  }

//🟢 --- EDIT KODE: GRAFIK GARIS KOMPATIBEL DENGAN MONGODB FASHION_TREND ---
  Widget _buildLineChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Obx(() {
        if (controller.isLoadingTrend.value) {
          return const SizedBox(
            height: 240,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.priceTrendData.isEmpty) {
          return const SizedBox(
            height: 240,
            child: Center(child: Text("Data tren harga belum tersedia")),
          );
        }

        // 1. Ambil daftar tanggal/bulan yang unik untuk label sumbu X (Maksimal 6)
        // Ini akan mengambil string seperti "January 2026", "February 2026", dst.
        List<String> listBulan = controller.priceTrendData
            .map((item) => item['date'].toString())
            .toSet()
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Tren Pergerakan Harga Hasil Scraping",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 4),
            const Text(
              "Harga (Rupiah)",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 240,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval:
                        20000, // Disesuaikan dengan rentang harga pakaian
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey[300], strokeWidth: 1),
                    getDrawingVerticalLine: (value) =>
                        FlLine(color: Colors.grey[300], strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const style =
                              TextStyle(color: Colors.black87, fontSize: 9);
                          int index = value.toInt();

                          // Menampilkan label bulan dari database secara dinamis
                          String text = '';
                          if (index >= 0 && index < listBulan.length) {
                            text = listBulan[index];
                          }

                          return Transform.translate(
                            offset: const Offset(-10, 5),
                            child: Transform.rotate(
                              angle: -0.3,
                              child: Text(text, style: style),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "${(value / 1000).toInt()}k",
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  minX: 0,
                  maxX:
                      listBulan.isEmpty ? 5 : (listBulan.length - 1).toDouble(),
                  // Mengatur batas dinamis sumbu Y agar grafik fleksibel mengikuti range harga scraping
                  minY: 100000,
                  maxY: 300000,
                  lineBarsData: _getFilteredChartData(listBulan),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // --- FILTER KATEGORI (BARU) ---
            _buildCategoryFilter(),
            
            const SizedBox(height: 24),

            // --- KOTAK LEGEND (Sama seperti bawaan Anda) ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Kategori Fitting",
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildLegendItem(const Color(0xFF66C2A5), "Boxy Fit"),
                      _buildLegendItem(const Color(0xFFFC8D62), "Fitted"),
                      _buildLegendItem(const Color(0xFF8DA0CB), "Oversize"),
                      _buildLegendItem(const Color(0xFFE78AC3), "Regular Fit"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // Helper baru untuk mencocokkan harga berdasarkan urutan bulan dan kategori
  List<FlSpot> _generateSpotsForCategory(
      List<String> listBulan, String namaKategori) {
    List<FlSpot> spots = [];
    for (int i = 0; i < listBulan.length; i++) {
      // Cari dokumen yang bulannya COCOK dan kategorinya COCOK
      var match = controller.priceTrendData.firstWhere(
        (item) =>
            item['date'] == listBulan[i] && item['category'] == namaKategori,
        orElse: () => {},
      );

      if (match.isNotEmpty) {
        num harga = match['price'] ?? 0;
        spots.add(FlSpot(i.toDouble(), harga.toDouble()));
      }
    }
    return spots;
  }

  // Helper untuk membuat konfigurasi garis secara instan (agar kode tidak panjang)
  // Helper: Membuat data grafik dinamis berdasarkan kategori yang dipilih
  List<LineChartBarData> _getFilteredChartData(List<String> listBulan) {
    String selected = controller.selectedCategory.value;
    List<LineChartBarData> allData = [];

    if (selected == 'All' || selected == 'Boxy Fit') {
      allData.add(_createLineData(
        color: const Color(0xFF66C2A5),
        spots: _generateSpotsForCategory(listBulan, "Boxy Fit"),
      ));
    }
    if (selected == 'All' || selected == 'Fitted') {
      allData.add(_createLineData(
        color: const Color(0xFFFC8D62),
        spots: _generateSpotsForCategory(listBulan, "Fitted"),
      ));
    }
    if (selected == 'All' || selected == 'Oversize') {
      allData.add(_createLineData(
        color: const Color(0xFF8DA0CB),
        spots: _generateSpotsForCategory(listBulan, "Oversize"),
      ));
    }
    if (selected == 'All' || selected == 'Regular Fit') {
      allData.add(_createLineData(
        color: const Color(0xFFE78AC3),
        spots: _generateSpotsForCategory(listBulan, "Regular Fit"),
      ));
    }

    return allData;
  }

  // Helper: Widget Filter Kategori Interaktif
  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: controller.categories.map((category) {
          bool isSelected = controller.selectedCategory.value == category;
          return GestureDetector(
            onTap: () => controller.changeCategory(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.blueAccent : Colors.grey[300]!,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(Icons.check, size: 16, color: Colors.blueAccent),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.blueAccent : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  LineChartBarData _createLineData(
      {required Color color, required List<FlSpot> spots}) {
    return LineChartBarData(
      spots: spots,
      isCurved: false, // 🟢 Garis Lurus (Tidak Melengkung)
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true, // 🟢 Tampilkan Titik
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 3,
            color: color,
            strokeWidth: 1,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData:
          BarAreaData(show: false), // 🟢 Hapus efek transparan di bawah garis
    );
  }

  // Helper untuk membuat item Legend
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ikon Garis dan Titik
        SizedBox(
          width: 20,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(height: 2, width: 20, color: color),
              Container(
                  height: 6,
                  width: 6,
                  decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1))),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black87)),
      ],
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
