import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:3000";

  static Future<dynamic> get(String endpoint, {String? token}) async {
    final url = Uri.parse("$baseUrl$endpoint");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

 static Future<dynamic> post(String endpoint, Map data, {String? token}) async {
  final url = Uri.parse("$baseUrl$endpoint");

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    },
    body: jsonEncode(data),
  );

  return jsonDecode(response.body);
}
}
