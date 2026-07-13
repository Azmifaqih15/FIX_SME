import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificationController extends GetxController {
  // Variabel reaktif untuk menyimpan array notifikasi dari backend
  var notifications = <dynamic>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications(); // Auto fetch saat aplikasi dibuka
  }

  // Fungsi untuk menandai satu notifikasi sebagai dibaca
  Future<void> markAsRead(int notificationId) async {
    try {
      final url = Uri.parse('https://backend-sme.up.railway.app/api/v1/notifications/$notificationId/read');
      final response = await http.put(
        url,
        headers: {'ngrok-skip-browser-warning': 'true'},
      );

      if (response.statusCode == 200) {
        int index = notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          // Update item agar UI ter-trigger reaktif
          var updatedNotif = Map<String, dynamic>.from(notifications[index]);
          updatedNotif['is_read'] = true;
          notifications[index] = updatedNotif;
        }
      } else {
        print("Gagal menandai dibaca: ${response.statusCode}");
      }
    } catch (e) {
      print("Error markAsRead: $e");
    }
  }

  // Fungsi untuk menandai semua notifikasi dibaca (menghapus list lokal sementara)
  void markAllAsRead() {
    notifications.clear();
  }

  // Fungsi menembak GET /api/v1/notifications
  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      // Gunakan URL yang sama dengan konfigurasi environment Anda
      final url = Uri.parse('https://backend-sme.up.railway.app/api/v1/notifications');
      final response = await http.get(
        url,
        headers: {'ngrok-skip-browser-warning': 'true'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['notifications'] != null) {
          notifications.value = data['notifications'];

          // --- LOGIKA POP-UP NOTIFIKASI ---
          if (notifications.isNotEmpty) {
            // Gunakan judul dari notifikasi pertama jika ada, atau teks default
            String title = notifications[0]['title'] ?? 'Pemberitahuan Sistem';
            
            // Periksa jika snackbar sudah terbuka agar tidak menumpuk berkali-kali jika dipanggil manual berulang
            if (!Get.isSnackbarOpen) {
              Get.snackbar(
                title,
                'Kamu memiliki ${notifications.length} notifikasi baru terkait stok dan penjualan!',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.blue.withOpacity(0.8),
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 4),
              );
            }
          }
        }
      } else {
        print("Gagal mengambil notifikasi: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetchNotifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Helper Warna & Ikon berdasarkan 'type' dari backend
  Color _getIconColor(String type) {
    if (type == 'bestseller' || type == 'profit') return Colors.green;
    if (type == 'low_stock') return Colors.orange;
    if (type == 'dead_stock') return Colors.red;
    return Colors.blue;
  }

  IconData _getIconData(String type) {
    if (type == 'bestseller') return Icons.star_rounded;
    if (type == 'profit') return Icons.attach_money_rounded;
    if (type == 'low_stock') return Icons.warning_rounded;
    if (type == 'dead_stock') return Icons.cancel_rounded;
    return Icons.notifications;
  }

  // Fungsi untuk memunculkan BottomSheet Notifikasi
  void showNotificationSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7, // Mengambil 70% tinggi layar
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Notifikasi Pintar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (isLoading.value && notifications.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (notifications.isEmpty) {
                  return Center(
                    child: Text(
                      "Tidak ada notifikasi saat ini.",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final title = notif['title'] ?? 'Info';
                    final message = notif['message'] ?? '';
                    final type = notif['type'] ?? 'info';
                    final isRead = notif['is_read'] == true;
                    final notifId = notif['id'];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      elevation: 0,
                      color: isRead ? Colors.white : const Color(0xFFEFF6FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isRead ? Colors.grey.shade200 : Colors.blue.shade200),
                      ),
                      child: ListTile(
                        onTap: () {
                          if (!isRead && notifId != null) {
                            markAsRead(notifId);
                          }
                        },
                        leading: CircleAvatar(
                          backgroundColor: _getIconColor(type).withOpacity(0.15),
                          child: Icon(
                            _getIconData(type),
                            color: _getIconColor(type),
                          ),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          message,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
    );
  }
}
