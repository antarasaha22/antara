import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';

class ApiService {
  final String baseUrl = "http://103.240.192.99"; // Use appropriate IP or hostname

  Future<List<Stock>> fetchStockData() async {
    final response = await http.get(Uri.parse('$baseUrl/watchlist'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Stock.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load stocks');
    }
  }
}
