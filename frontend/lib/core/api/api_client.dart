import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // Базовий URL нашого Flask-бекенду
  static const String baseUrl = 'http://127.0.0.1:5000/api';

  // Стандартні заголовки для REST API
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET запит
  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _processResponse(response);
  }

  // POST запит
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  // PUT запит
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  // DELETE запит
  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _processResponse(response);
  }

  // Універсальний обробник відповідей від Flask
  static dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      // Якщо Flask повернув помилку, витягуємо її текст
      final errorBody = jsonDecode(response.body);
      throw Exception(
        errorBody['error'] ?? 'Помилка сервера: ${response.statusCode}',
      );
    }
  }
}
