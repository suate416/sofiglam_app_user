import 'dart:convert';

import 'package:http/http.dart' as http;
import '../Models/productos_model.dart';

class ProductoService {
  static const String _baseUrl = 'http://10.0.2.2:3008/api/productos';

  Future<List<Producto>> fetchProductos() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> data = jsonData;
      return data.map((producto) => Producto.fromJson(producto)).toList();
    } else {
      throw Exception('Error fetching products: ${response.statusCode}');
    }
  }
}