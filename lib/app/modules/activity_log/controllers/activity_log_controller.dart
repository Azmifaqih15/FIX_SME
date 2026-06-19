import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivityLogController extends GetxController {
  // Menggunakan list yang berisi Map untuk mengelompokkan data berdasarkan tanggal
  var groupedLogs = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() {
    groupedLogs.value = [
      {
        "date": "Today",
        "logs": [
          {
            "title": "Added new product 'Basic White Tee'",
            "time": "10:30 AM",
            "icon": Icons.add_box_rounded,
            "color": Colors.green,
          },
          {
            "title": "Logged in via Face ID",
            "time": "08:00 AM",
            "icon": Icons.face_retouching_natural_rounded,
            "color": Colors.purple,
          },
        ]
      },
      {
        "date": "Yesterday",
        "logs": [
          {
            "title": "Generated PO for 'Lavender Soap'",
            "time": "15:45 PM",
            "icon": Icons.sync_rounded,
            "color": Colors.blue,
          },
          {
            "title": "Updated stock 'Oversize Hoodie'",
            "time": "11:20 AM",
            "icon": Icons.inventory_2_rounded,
            "color": Colors.orange,
          },
        ]
      },
      {
        "date": "18 June 2026",
        "logs": [
          {
            "title": "Changed status 'Black Denim' to WARNING",
            "time": "16:10 PM",
            "icon": Icons.warning_rounded,
            "color": Colors.red,
          },
          {
            "title": "System AI stock prediction alert",
            "time": "09:00 AM",
            "icon": Icons.auto_awesome,
            "color": Colors.indigo,
          },
        ]
      }
    ];
  }
}
