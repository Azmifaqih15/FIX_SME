import 'package:get/get.dart';

class NotificationController extends GetxController {
  // Observable list untuk menampung data notifikasi
  var notifications = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() {
    // Data dummy yang relevan dengan skenario Smart-SME
    notifications.value = [
      {
        "id": 1,
        "title": "AI Stockout Alert 🚨",
        "message":
            "Sistem AI memprediksi 'Premium Lavender Organic Soap' akan habis dalam 3 hari (14 Nov). Disarankan segera melakukan Purchase Order sebanyak 800 unit.",
        "time": "10 menit yang lalu",
        "type": "ai_alert",
        "isRead": false,
      },
      {
        "id": 2,
        "title": "Keamanan Biometrik Aktif 🛡️",
        "message":
            "Fitur Face ID Login telah berhasil diaktifkan di perangkat ini. Akun Anda sekarang lebih aman.",
        "time": "2 jam yang lalu",
        "type": "security",
        "isRead": false,
      },
      {
        "id": 3,
        "title": "Tren Pasar Meningkat 📈",
        "message":
            "Analisis pasar menunjukkan permintaan untuk kategori 'Oversize T-Shirt' naik 14% kuartal ini.",
        "time": "Kemarin, 14:30",
        "type": "market_trend",
        "isRead": true,
      },
      {
        "id": 4,
        "title": "Laporan Penjualan Mingguan 📊",
        "message":
            "Laporan performa toko minggu pertama bulan ini sudah tersedia untuk diunduh.",
        "time": "Kemarin, 09:00",
        "type": "info",
        "isRead": true,
      },
      {
        "id": 5,
        "title": "Status Produk Diperbarui 📦",
        "message":
            "Anda mengubah status 'Basic White Tee' dari NORMAL menjadi WARNING secara manual.",
        "time": "3 hari yang lalu",
        "type": "info",
        "isRead": true,
      },
    ];
  }

  // Fungsi untuk menandai notifikasi sudah dibaca saat diklik
  void markAsRead(int index) {
    if (!notifications[index]['isRead']) {
      // Membuat salinan Map agar Obx mendeteksi perubahan
      var updatedNotif = Map<String, dynamic>.from(notifications[index]);
      updatedNotif['isRead'] = true;
      notifications[index] = updatedNotif;
    }
  }

  // Fungsi untuk menandai semua sudah dibaca
  void markAllAsRead() {
    var updatedList = notifications.map((notif) {
      var copy = Map<String, dynamic>.from(notif);
      copy['isRead'] = true;
      return copy;
    }).toList();
    notifications.value = updatedList;
  }
}
