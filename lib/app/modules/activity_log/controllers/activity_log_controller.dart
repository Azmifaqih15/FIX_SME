import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_sme_app/app/data/api_config.dart';
import '../models/activity_log_model.dart';

class ActivityLogController extends GetxController {
  RxList<ActivityLogModel> activityLogs = <ActivityLogModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    try {
      isLoading.value = true;
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      
      String url = '${ApiConfig.BASE_URL}/logs';
      if (userId != null && userId.isNotEmpty) {
        url += '?user_id=$userId';
      }
      
      ApiConfig.logNetwork(url);
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        List data = [];
        
        if (jsonResponse is List) {
          data = jsonResponse;
        } else if (jsonResponse is Map && jsonResponse['data'] != null) {
          data = jsonResponse['data'];
        }
        
        activityLogs.assignAll(data.map((e) => ActivityLogModel.fromJson(e)).toList());
      } else {
        print("Gagal fetch logs: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetch logs: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
