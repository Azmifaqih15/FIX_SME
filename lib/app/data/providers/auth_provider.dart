import 'package:get/get.dart';

class AuthProvider extends GetConnect {
  // Fungsi Login ke Server
  Future<Response> login(String email, String password) => 
      post('https://api-anda.com/login', {'email': email, 'password': password});

  // Fungsi Register ke Server
  Future<Response> register(String name, String email, String password) => 
      post('https://api-anda.com/register', {
        'name': name,
        'email': email, 
        'password': password
      });
}