import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../routes/app_pages.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF111E38);
    const Color accentColor = Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: const Color(
          0xFFF8FAFC), // Latar belakang abu-abu sangat muda di luar header
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION MENYATU ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[50]!,
                    Colors.white,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // APP BAR TRANSPARAN
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                              width:
                                  48), // Spacing agar title bisa pas di tengah
                          const Text(
                            'My Profile',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Get.defaultDialog(
                                title: "Logout",
                                middleText: "Are you sure you want to log out?",
                                textConfirm: "Yes",
                                textCancel: "Cancel",
                                confirmTextColor: Colors.white,
                                buttonColor: Colors.redAccent,
                                onConfirm: () {
                                  Get.back();
                                  controller.logout();
                                },
                              );
                            },
                            icon: const Icon(Icons.logout_rounded,
                                color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // AVATAR DENGAN BORDER PUTIH TIPIS
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white, // Border putih
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 60,
                        backgroundColor: Color(0xFFEEF2FF),
                        child: Icon(Icons.person, size: 60, color: accentColor),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // NAMA DAN EMAIL
                    Obx(() => Text(
                          controller.name.value,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        )),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          controller.email.value,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF475569), // Abu-abu gelap
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                    const SizedBox(height: 20),

                    // TOMBOL EDIT PROFILE (OUTLINED BUTTON MINIMALIS)
                    OutlinedButton.icon(
                      onPressed: controller.editProfile,
                      icon: const Icon(Icons.edit,
                          size: 16, color: Color(0xFF1E293B)),
                      label: const Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFCBD5E1), width: 1.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- SETTINGS SECTION (KARTU BERSIH) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 1.5,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _buildMenuTile(
                              Icons.storefront_rounded,
                              "Business Information",
                              "Manage store & warehouse details",
                              onTap: () => Get.toNamed(Routes.BUSINESS_INFO)),
                          const Divider(
                              height: 1,
                              indent: 64,
                              endIndent: 24,
                              color: Color(0xFFF1F5F9)),
                          _buildMenuTile(Icons.shield_rounded, "Security",
                              "Password, Face ID, & PIN",
                              onTap: () => Get.toNamed(Routes.SECURITY)),
                          const Divider(
                              height: 1,
                              indent: 64,
                              endIndent: 24,
                              color: Color(0xFFF1F5F9)),
                          _buildMenuTile(Icons.notifications_rounded,
                              "Notifications", "Manage push alerts", onTap: () {
                            Get.toNamed(Routes.NOTIFICATION);
                          }),
                          const Divider(
                              height: 1,
                              indent: 64,
                              endIndent: 24,
                              color: Color(0xFFF1F5F9)),
                          _buildMenuTile(
                            Icons.receipt_long_rounded,
                            "Activity Log",
                            "View your activity history",
                            onTap: () => Get.toNamed('/activity-log'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- TOMBOL LOGOUT UTAMA ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.defaultDialog(
                          title: "Logout",
                          middleText: "Are you sure you want to log out?",
                          textConfirm: "Yes",
                          textCancel: "Cancel",
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.redAccent,
                          onConfirm: () {
                            Get.back();
                            controller.logout();
                          },
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Colors.redAccent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 4,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey[400],
          elevation: 0,
          onTap: controller.changePage,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded), label: "Dashboard"),
            BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined), label: "Inventory"),
            BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner), label: "Scan"),
            BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined), label: "Market"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }

  // WIDGET HELPER MENU
  Widget _buildMenuTile(IconData icon, String title, String subtitle,
      {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF1E293B), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF1E293B)),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          size: 20, color: Color(0xFF94A3B8)),
      onTap: onTap,
    );
  }
}
