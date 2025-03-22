import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Models/categoria_model.dart';

class CategoriaService {
  static const String _baseUrl = 'http://10.0.2.2:3008/api/categorias';

  Future<List<Categoria>> fetchCategorias() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((categoria) => Categoria.fromJson(categoria)).toList();
      } else {
        throw Exception('Error fetching categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}