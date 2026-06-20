import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color bgColor =
        Color(0xFFF8FAFC); // Background abu-abu kebiruan terang

    // Inisialisasi controller secara langsung jika belum melalui Route Binding
    // Get.put(NotificationController()); // Hapus komentar ini jika tidak pakai AppPages binding

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: controller.markAllAsRead,
            child: const Text(
              "Tandai Semua Terbaca",
              style: TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.w600,
                  fontSize: 12),
            ),
          )
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return const Center(child: Text("Belum ada notifikasi."));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: controller.notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final notif = controller.notifications[index];
            final bool isRead = notif['isRead'];

            return InkWell(
              onTap: () => controller.markAsRead(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isRead ? Colors.white : Colors.blue[50]?.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isRead ? Colors.grey[200]! : Colors.blue[200]!,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ikon Kategori
                    _buildIcon(notif['type']),
                    const SizedBox(width: 16),

                    // Teks Konten
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notif['title'],
                                  style: TextStyle(
                                    fontWeight: isRead
                                        ? FontWeight.w600
                                        : FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.blueAccent,
                                    shape: BoxShape.circle,
                                  ),
                                )
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notif['message'],
                            style: TextStyle(
                              fontSize: 12,
                              color: isRead ? Colors.grey[600] : Colors.black87,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notif['time'],
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // Widget pembantu untuk menghasilkan ikon berdasarkan tipe notifikasi
  Widget _buildIcon(String type) {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (type) {
      case 'ai_alert':
        iconData = Icons.auto_awesome;
        iconColor = Colors.purple[700]!;
        bgColor = Colors.purple[50]!;
        break;
      case 'security':
        iconData = Icons.security_rounded;
        iconColor = Colors.green[700]!;
        bgColor = Colors.green[50]!;
        break;
      case 'market_trend':
        iconData = Icons.trending_up_rounded;
        iconColor = Colors.orange[700]!;
        bgColor = Colors.orange[50]!;
        break;
      case 'info':
      default:
        iconData = Icons.info_outline_rounded;
        iconColor = Colors.blue[700]!;
        bgColor = Colors.blue[50]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }
}
