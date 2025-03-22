import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/carrito_model.dart';

class CarritoService {
  static const String _baseUrl = 'http://10.0.2.2:3008/api/carrito';
  final String sessionId = 'test1';

  // Get or create cart
  Future<Carrito> obtenerCrearCarrito() async {
    try {
      // Assuming user ID 1 for simplicity - in a real app, get this from auth
      
      final response = await http.get(
        Uri.parse(_baseUrl),
      );

      if (response.statusCode == 200) {
        return Carrito.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        // Cart not found, create a new one
        final createResponse = await http.post(
          Uri.parse(_baseUrl),
        );

        if (createResponse.statusCode == 201) {
          return Carrito.fromJson(json.decode(createResponse.body));
        } else {
          throw Exception('Error creating cart: ${createResponse.statusCode}');
        }
      } else {
        throw Exception('Error fetching cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load or create cart: $e');
    }
  }


  Future<Carrito> obtenerCarritoConDetalles() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
      );

      if (response.statusCode == 200) {
        return Carrito.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error fetching cart details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load cart details: $e');
    }
  }

  // Add product to cart
  Future<void> agregarProductoAlCarrito(
    int idCarrito,
    int idProducto,
    int cantidad,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/agregar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_carrito': idCarrito,
          'id_producto': idProducto,
          'cantidad': cantidad
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Error adding product to cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al agregar producto: $e');
    }
  }

  // Update item quantity
  Future<void> actualizarCantidadDetalle(int idDetalle, int nuevaCantidad) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/detalle/$idDetalle'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'cantidad': nuevaCantidad}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error updating quantity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update quantity: $e');
    }
  }

  // Remove item from cart
  Future<void> eliminarDetalleCarrito(int idDetalle) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/detalle/$idDetalle'),
      );

      if (response.statusCode != 200) {
        throw Exception('Error removing product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to remove product: $e');
    }
  }

  // Process purchase/checkout
  Future<void> procesarCompra(int idCarrito) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$idCarrito/checkout'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error processing purchase: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to process purchase: $e');
    }
  }
}