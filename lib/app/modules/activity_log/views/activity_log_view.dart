import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/activity_log_controller.dart'; 

class ActivityLogView extends GetView<ActivityLogController> {
  const ActivityLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], 
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
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.activityLogs.isEmpty) {
          return const Center(
            child: Text("Belum ada aktivitas",
                style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.activityLogs.length,
          itemBuilder: (context, index) {
            final log = controller.activityLogs[index];
            
            Color iconColor = Colors.blue;
            IconData iconData = Icons.info_outline;
            
            if (log.actionType == 'SCAN_IN') {
              iconColor = Colors.green;
              iconData = Icons.login_rounded;
            } else if (log.actionType == 'SCAN_OUT') {
              iconColor = Colors.redAccent;
              iconData = Icons.logout_rounded;
            } else {
              iconColor = Colors.blue;
              iconData = Icons.article_outlined;
            }

            String formattedTime = "${log.createdAt.day}/${log.createdAt.month}/${log.createdAt.year} ${log.createdAt.hour.toString().padLeft(2, '0')}:${log.createdAt.minute.toString().padLeft(2, '0')}";

            return Card(
              color: Colors.white,
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor),
                ),
                title: Text(
                  log.description,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  formattedTime,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
