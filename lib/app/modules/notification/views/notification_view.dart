import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Notifikasi Pintar', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () => controller.markAllAsRead(),
            child: const Text("Tandai Semua Dibaca", style: TextStyle(color: Colors.blue)),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text("Tidak ada notifikasi", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notif = controller.notifications[index];
              final type = notif['type'] ?? 'info';
              final title = notif['title'] ?? 'Notifikasi';
              final message = notif['message'] ?? '';
              final isRead = notif['is_read'] == true;
              final notifId = notif['id'];

              // Tentukan ikon dan warna berdasarkan tipe notifikasi
              IconData iconData = Icons.info_outline;
              Color iconColor = Colors.blue;
              Color bgColor = Colors.blue.withOpacity(0.1);

              if (type == 'profit' || type == 'bestseller') {
                iconData = Icons.trending_up;
                iconColor = Colors.green;
                bgColor = Colors.green.withOpacity(0.1);
              } else if (type == 'low_stock' || type == 'dead_stock') {
                iconData = Icons.warning_amber_rounded;
                iconColor = Colors.red;
                bgColor = Colors.red.withOpacity(0.1);
              } else if (type == 'alert') {
                iconData = Icons.error_outline;
                iconColor = Colors.orange;
                bgColor = Colors.orange.withOpacity(0.1);
              }

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                color: isRead ? Colors.white : const Color(0xFFEFF6FF), // Latar belakang kebiruan jika belum dibaca
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isRead ? Colors.grey.shade200 : Colors.blue.shade200),
                ),
                child: ListTile(
                  onTap: () {
                    if (!isRead && notifId != null) {
                      controller.markAsRead(notifId);
                    }
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: iconColor),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      message,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ),
                  trailing: !isRead 
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ) 
                    : null,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
