import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/activity_log_controller.dart'; // Sesuaikan path Anda

class ActivityLogView extends GetView<ActivityLogController> {
  const ActivityLogView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Activity Log",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.groupedLogs.isEmpty) {
          return const Center(
            child: Text("No activity recorded yet.",
                style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.groupedLogs.length,
          itemBuilder: (context, index) {
            final group = controller.groupedLogs[index];
            final String date = group['date'];
            final List<dynamic> logs = group['logs'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Tanggal (Today, Yesterday, dll)
                Padding(
                  padding: EdgeInsets.only(
                      left: 8, bottom: 12, top: index == 0 ? 0 : 20),
                  child: Text(
                    date,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B), // Abu-abu kebiruan
                    ),
                  ),
                ),

                // Kartu berisi daftar aktivitas di hari tersebut
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: logs.length,
                    separatorBuilder: (context, idx) => const Divider(
                        height: 1,
                        indent: 64,
                        endIndent: 24,
                        color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, idx) {
                      final log = logs[idx];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (log['color'] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(log['icon'], color: log['color'], size: 20),
                        ),
                        title: Text(
                          log['title'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF1E293B)),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            log['time'],
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
