import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/carrito_model.dart';
import '../Models/cliente_model.dart';
import 'carrito_services.dart';

class CompraService {
  static const String _baseUrl = 'http://10.0.2.2:3009/api';

  Future<int> procesarCompra({
    required Cliente cliente,
    required Carrito carrito,
    required String metodoPago,
    String? referenciaPago,
    String? notas,
  }) async {
    try {
      // 1. Crear cliente
      final clienteResponse = await http.post(
        Uri.parse('$_baseUrl/clientes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(cliente.toJson()),
      );

      if (clienteResponse.statusCode != 200 &&
          clienteResponse.statusCode != 201) {
        throw Exception(
            'Error al crear cliente: ${clienteResponse.statusCode} - ${clienteResponse.body}');
      }

      // Obtener el ID del cliente creado
      final clienteData = json.decode(clienteResponse.body);
      final int idCliente = clienteData['id_cliente'];

      // 2. Preparar los productos del carrito
      final List<Map<String, dynamic>> productosArray = [];

      print('Preparando productos para la compra:');
      print('Carrito ID: ${carrito.idCarrito}');
      print('Subtotal: ${carrito.total}');
      print('Productos en carrito: ${carrito.carritoProductos?.length ?? 0}');

      if (carrito.carritoProductos != null) {
        for (var producto in carrito.carritoProductos!) {
          print(
              'Procesando producto: ID=${producto.idProducto}, Cantidad=${producto.cantidad}');

          productosArray.add({
            'id_producto': producto.idProducto,
            'cantidad': producto.cantidad,
            'precio_unitario': producto.precioUnitario.toString()
          });
        }
      }

      // Validar que tenemos productos
      if (productosArray.isEmpty) {
        // Intentar cargar los productos nuevamente antes de fallar
        print(
            'No se encontraron productos en el carrito, intentando refrescar...');
        try {
          // Llamamos al servicio de carrito para obtener los productos actualizados
          final carritoService = CarritoService();
          final carritoActualizado =
              await carritoService.obtenerCarritoConDetalles();

          if (carritoActualizado.carritoProductos != null &&
              carritoActualizado.carritoProductos!.isNotEmpty) {
            print(
                'Carrito actualizado con ${carritoActualizado.carritoProductos!.length} productos');

            for (var producto in carritoActualizado.carritoProductos!) {
              print(
                  'Añadiendo producto recuperado: ID=${producto.idProducto}, Cantidad=${producto.cantidad}');

              productosArray.add({
                'id_producto': producto.idProducto,
                'cantidad': producto.cantidad,
                'precio_unitario': producto.precioUnitario.toString()
              });
            }
          }
        } catch (e) {
          print('Error al intentar refrescar el carrito: $e');
        }
      }

      // Verificar nuevamente si tenemos productos
      if (productosArray.isEmpty) {
        throw Exception('El carrito no contiene productos para procesar');
      }

      print('Productos listos para procesar: ${productosArray.length}');

      // 3. Crear compra con los productos incluidos
      final compraData = {
        'fecha': DateTime.now().toIso8601String(),
        'estado': 'Pendiente',
        'total': carrito.total,
        'metodo_pago': metodoPago,
        'referencia_pago': referenciaPago ?? '',
        'notas': notas ?? '',
        'id_cliente': idCliente,
        'productos': productosArray
      };

      // Imprimir datos completos para depuración
      print('=== DATOS DE COMPRA ENVIADOS ===');
      print('ID Cliente: $idCliente');
      print('Total: ${carrito.total}');
      print('Método de pago: $metodoPago');
      print('Productos:');
      for (var producto in productosArray) {
        print(
            '- ID: ${producto['id_producto']}, Cantidad: ${producto['cantidad']}, Precio: ${producto['precio_unitario']}');
      }
      print('JSON completo: ${json.encode(compraData)}');
      print('=============================');

      final compraResponse = await http.post(
        Uri.parse('$_baseUrl/compras'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(compraData),
      );

      print(
          'Respuesta del servidor: ${compraResponse.statusCode} - ${compraResponse.body}');

      if (compraResponse.statusCode != 200 &&
          compraResponse.statusCode != 201) {
        throw Exception(
            'Error al crear compra: ${compraResponse.statusCode} - ${compraResponse.body}');
      }

      // Obtener el ID de la compra creada
      final compraResponseData = json.decode(compraResponse.body);
      print('Estructura de la respuesta: ${compraResponseData.runtimeType}');

      int idCompra = 0;
      // Comprobar si el ID está en la respuesta principal o dentro del objeto 'data'
      if (compraResponseData is Map<String, dynamic>) {
        if (compraResponseData.containsKey('id_compra')) {
          idCompra = compraResponseData['id_compra'];
        } else if (compraResponseData.containsKey('id')) {
          idCompra = compraResponseData['id'];
        } else if (compraResponseData.containsKey('data') &&
            compraResponseData['data'] is Map<String, dynamic>) {
          // El ID está anidado dentro del objeto 'data'
          final data = compraResponseData['data'];
          if (data.containsKey('id_compra')) {
            idCompra = data['id_compra'];
          } else if (data.containsKey('id')) {
            idCompra = data['id'];
          }
        }
      }

      print('ID de compra recuperado: $idCompra');

      if (idCompra == 0) {
        throw Exception('No se pudo obtener el ID de la compra creada');
      }

      return idCompra;
    } catch (e) {
      print('Error completo al procesar compra: $e');
      throw Exception('Error al procesar compra: $e');
    }
  }
}
