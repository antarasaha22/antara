import 'dart:convert';  // For jsonEncode and jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;  // For HTTP requests
import 'models/stock.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Angel One App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StockListScreen(),
      debugShowCheckedModeBanner: false
    );
  }
}

class StockListScreen extends StatefulWidget {
  @override
  _StockListScreenState createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  List<Stock> _stocks = [];
  final _stockNameController = TextEditingController();
  final _symbolController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStocks();
  }

  Future<void> _fetchStocks() async {
    try {
      final response = await http.get(Uri.parse('http://103.240.192.99/api/watchlist'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _stocks = data.map((json) => Stock.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load stocks');
      }
    } catch (e) {
      print('Error fetching stocks: $e'); // Debugging line
    }
  }

  Future<void> _addStock() async {
  final stockName = _stockNameController.text;
  final symbol = _symbolController.text;

  if (stockName.isEmpty || symbol.isEmpty) {
    return; // Prevent adding empty stocks
  }

  try {
    final response = await http.post(
      Uri.parse('http://103.240.192.99/api/addStock'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'stock_name': stockName,
        'symbol': symbol,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final newStock = Stock.fromJson(jsonDecode(response.body));
      setState(() {
        _stocks.add(newStock);
      });
      _stockNameController.clear();
      _symbolController.clear();
    } else {
      throw Exception('Failed to add stock');
    }
  } catch (e) {
    print('Error adding stock: $e'); // Debugging line
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Watchlist'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _stockNameController,
                    decoration: InputDecoration(
                      labelText: 'Stock Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _symbolController,
                    decoration: InputDecoration(
                      labelText: 'Symbol',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addStock,
                  child: Text('Add Stock'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _stocks.isEmpty
                ? Center(child: Text('No stocks available'))
                : ListView.builder(
                    itemCount: _stocks.length,
                    itemBuilder: (context, index) {
                      final stock = _stocks[index];
                      return ListTile(
                        title: Text(stock.stockName),
                        subtitle: Text(stock.symbol),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
