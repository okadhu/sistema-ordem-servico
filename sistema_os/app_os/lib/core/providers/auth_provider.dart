import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';
class AuthProvider extends ChangeNotifier {
  UserModel? user;
  String? token;

  Future<bool> login(String email, String senha) async {
    final result = await ApiService.post("/auth/login", {
      "email": email,
      "password": senha,
    });

    // tenta várias chaves possíveis
    final userJson = 
        result["user"] ??
        result["usuario"] ??
        result["data"] ??
        result;

    if (result["token"] != null && userJson != null) {
      token = result["token"];
      user = UserModel.fromJson(userJson);
      notifyListeners();
      return true;
    }

    return false;
  }

  bool get isLogged => token != null;
}
