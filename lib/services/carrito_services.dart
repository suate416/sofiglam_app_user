import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/carrito_model.dart';
import '../Models/carrito_producto_model.dart';
import '../Models/productos_model.dart';
import '../Models/categoria_model.dart';

class CarritoService {
  static const String _baseUrl = 'http://10.0.2.2:3009/api/carritos';
  // Variable estática para almacenar el ID del carrito temporalmente
  static int? _carritoIdTemp;

  // Método para obtener el ID del carrito guardado
  Future<int?> _getStoredCarritoId() async {
    // Simplemente devolver el ID temporal guardado en memoria
    return _carritoIdTemp;
  }

  // Método para guardar el ID del carrito
  Future<void> _storeCarritoId(int id) async {
    // Almacenar el ID temporalmente en memoria
    _carritoIdTemp = id;
  }

  // Get or create cart
  Future<Carrito> obtenerCrearCarrito() async {
    try {
      // Verificar si ya tenemos un ID de carrito guardado
      final storedCarritoId = _carritoIdTemp;

      if (storedCarritoId != null) {
        // Intenta obtener el carrito con el ID guardado
        try {
          final carritoResponse = await http.get(
            Uri.parse('$_baseUrl/$storedCarritoId'),
          );

          // Si encuentra el carrito, retornarlo
          if (carritoResponse.statusCode == 200) {
            final detalles = json.decode(carritoResponse.body);
            // Creamos un objeto carrito básico ya que la respuesta es diferente
            final carrito = Carrito(
              idCarrito: storedCarritoId,
              fechaCreacion:
                  DateTime.now(), // No importa pues ya tenemos el carrito
              total: detalles['subtotal'] != null
                  ? double.parse(detalles['subtotal'].toString())
                  : 0.0,
              sesionId: '',
              expiraEn: DateTime.now().add(const Duration(days: 1)),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              carritoProductos: [], // Se llenarán en otra solicitud si es necesario
            );
            return carrito;
          }
        } catch (e) {
          // Ignorar error y continuar para crear un nuevo carrito
          print('Error al obtener carrito guardado: $e');
        }
      }

      // Si no hay ID guardado o no se pudo obtener el carrito, crear uno nuevo
      final response = await http.get(
        Uri.parse(_baseUrl),
      );

      if (response.statusCode == 200) {
        final carrito = Carrito.fromJson(json.decode(response.body));
        // Guardar el ID del carrito para futuras solicitudes
        _carritoIdTemp = carrito.idCarrito;
        return carrito;
      } else {
        throw Exception('Error al obtener carrito: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar o crear carrito: $e');
    }
  }

  Future<Carrito> obtenerCarritoConDetalles() async {
    try {
      // Obtener el ID del carrito guardado
      final storedCarritoId = _carritoIdTemp;

      if (storedCarritoId == null) {
        // Si no hay ID guardado, obtener un nuevo carrito
        return obtenerCrearCarrito();
      }

      // Obtener detalles del carrito
      final detallesResponse = await http.get(
        Uri.parse('$_baseUrl/$storedCarritoId/productos'),
      );

      print('Respuesta completa del carrito: ${detallesResponse.body}');

      if (detallesResponse.statusCode == 200) {
        // Intentamos decodificar directamente como una lista de productos
        List<dynamic> productosJson = [];
        double subtotal = 0.0;

        try {
          final decodedResponse = json.decode(detallesResponse.body);
          print('Tipo de respuesta: ${decodedResponse.runtimeType}');

          // Procesamos directamente como una lista de productos
          if (decodedResponse is List) {
            productosJson = decodedResponse;
            print(
                'Lista de productos recibida: ${productosJson.length} productos');
          } else if (decodedResponse is Map<String, dynamic>) {
            // Es un objeto, buscamos productos dentro de él
            if (decodedResponse.containsKey('productos')) {
              productosJson = decodedResponse['productos'] as List<dynamic>;
            } else if (decodedResponse.containsKey('data')) {
              // A veces la API envuelve los datos en un campo 'data'
              var data = decodedResponse['data'];
              if (data is List) {
                productosJson = data;
              } else if (data is Map<String, dynamic> &&
                  data.containsKey('productos')) {
                productosJson = data['productos'] as List<dynamic>;
              }
            }
          }

          // Si no tenemos productos, intentamos otra URL alternativa
          if (productosJson.isEmpty) {
            try {
              final alternativeResponse = await http.get(
                Uri.parse('$_baseUrl/$storedCarritoId'),
              );

              if (alternativeResponse.statusCode == 200) {
                final altData = json.decode(alternativeResponse.body);
                print('Respuesta alternativa: $altData');

                if (altData is List) {
                  productosJson = altData;
                } else if (altData is Map<String, dynamic>) {
                  if (altData.containsKey('productos')) {
                    productosJson = altData['productos'] as List<dynamic>;
                  } else if (altData.containsKey('CarritoProductos')) {
                    productosJson =
                        altData['CarritoProductos'] as List<dynamic>;
                  }

                  // Si encontramos subtotal, usarlo
                  if (altData.containsKey('subtotal')) {
                    subtotal = double.parse(altData['subtotal'].toString());
                  }
                }
              }
            } catch (e) {
              print('Error al intentar URL alternativa: $e');
            }
          }
        } catch (e) {
          print('Error al decodificar respuesta: $e');
        }

        // Convertir productos JSON a objetos CarritoProducto
        List<CarritoProducto> productos = [];

        if (productosJson.isNotEmpty) {
          print('Procesando ${productosJson.length} productos del carrito:');
          for (var p in productosJson) {
            print('Producto raw: $p');
            try {
              // Extraer información del producto
              final id = p['id'] ?? p['id_detalle'] ?? 0;
              final idProducto = p['id_producto'] ?? p['idProducto'] ?? 0;
              final cantidad = p['cantidad'] ?? 1;
              final precioStr = (p['precio_unitario'] ??
                      p['precioUnitario'] ??
                      p['precio'] ??
                      '0')
                  .toString();
              final precioUnitario = double.parse(precioStr);

              // Calcular subtotal si no lo tenemos
              subtotal += precioUnitario * cantidad;

              // Crear objeto Producto si está disponible
              Producto? producto;
              if (p['Producto'] != null) {
                try {
                  // Algunos campos pueden faltar en la respuesta de la API
                  Map<String, dynamic> productoJson = p['Producto'];

                  // Crear objeto con valores por defecto para campos faltantes
                  producto = Producto(
                    idProducto: idProducto,
                    nombre: productoJson['nombre'] ?? 'Producto sin nombre',
                    descripcion: productoJson['descripcion'] ?? '',
                    precio: double.parse(
                        (productoJson['precio'] ?? '0').toString()),
                    file: productoJson['file'] ??
                        'https://via.placeholder.com/80',
                    stock: productoJson['stock'] ?? 10,
                    genero: productoJson['genero'] ?? 'Unisex',
                    material: productoJson['material'] ?? 'No especificado',
                    idCategoria: productoJson['id_categoria'] ?? 1,
                    categoria: Categoria(
                        idCategoria: productoJson['id_categoria'] ?? 1,
                        nombre: 'General'),
                  );

                  print('Producto procesado correctamente: ${producto.nombre}');
                } catch (e) {
                  print('Error al procesar objeto Producto: $e');

                  // Si falla, crear un producto básico
                  producto = Producto(
                    idProducto: idProducto,
                    nombre: p['Producto']?['nombre'] ?? 'Producto #$idProducto',
                    descripcion: p['Producto']?['descripcion'] ?? '',
                    precio: precioUnitario,
                    file: p['Producto']?['file'] ??
                        'https://via.placeholder.com/80',
                    stock: 10,
                    idCategoria: 1,
                    genero: 'Unisex',
                    material: 'No especificado',
                    categoria: Categoria(idCategoria: 1, nombre: 'General'),
                  );
                }
              } else {
                // Si no tenemos el objeto Producto completo, creamos uno básico con valores predeterminados
                producto = Producto(
                  idProducto: idProducto,
                  nombre: p['nombre'] ?? 'Producto #$idProducto',
                  descripcion: p['descripcion'] ?? '',
                  precio: precioUnitario,
                  file: p['file'] ??
                      p['imagen'] ??
                      'https://via.placeholder.com/80',
                  stock: 10,
                  idCategoria: 1,
                  genero: 'Unisex',
                  material: 'No especificado',
                  categoria: Categoria(idCategoria: 1, nombre: 'General'),
                );
              }

              // Crear objeto CarritoProducto
              final carritoProducto = CarritoProducto(
                id: id,
                idProducto: idProducto,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
                idCarrito: storedCarritoId,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                producto: producto,
              );

              productos.add(carritoProducto);
              print(
                  'Producto procesado: ${carritoProducto.idProducto} - ${producto.nombre}');
            } catch (e) {
              print('Error procesando producto individual: $e');
            }
          }
        } else {
          print('No se encontraron productos en el carrito');
        }

        // Crear objeto Carrito con los productos procesados
        final carrito = Carrito(
          idCarrito: storedCarritoId,
          fechaCreacion: DateTime.now(),
          total: subtotal,
          sesionId: '',
          expiraEn: DateTime.now().add(const Duration(days: 1)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          carritoProductos: productos.isEmpty ? null : productos,
        );

        print(
            'Carrito final procesado: ID=${carrito.idCarrito}, Productos=${carrito.carritoProductos?.length ?? 0}, Subtotal=${carrito.total}');

        if (carrito.carritoProductos == null ||
            carrito.carritoProductos!.isEmpty) {
          print(
              'ADVERTENCIA: Carrito vacío después de procesar la respuesta del servidor');
        }

        return carrito;
      } else if (detallesResponse.statusCode == 404) {
        // Si el carrito no existe, borrar el ID guardado y obtener uno nuevo
        _carritoIdTemp = null;
        return obtenerCrearCarrito();
      } else {
        print(
            'Error HTTP: ${detallesResponse.statusCode}, Body: ${detallesResponse.body}');
        throw Exception(
            'Error al obtener detalles del carrito: ${detallesResponse.statusCode}');
      }
    } catch (e) {
      print('Error completo al cargar detalles del carrito: $e');
      throw Exception('Error al cargar detalles del carrito: $e');
    }
  }

  // Add product to cart
  Future<void> agregarProductoAlCarrito(
    int idProducto,
    int cantidad,
  ) async {
    try {
      // Obtener el ID del carrito guardado o crear uno nuevo si no existe
      int idCarrito;

      if (_carritoIdTemp != null) {
        idCarrito = _carritoIdTemp!;
        print('Usando carrito existente ID: $idCarrito');
      } else {
        // Si no hay carrito guardado, obtener uno nuevo
        print('Creando nuevo carrito...');
        final carrito = await obtenerCrearCarrito();
        idCarrito = carrito.idCarrito;
        _carritoIdTemp = idCarrito;
        print('Nuevo carrito creado con ID: $idCarrito');
      }

      print(
          'Agregando producto $idProducto (cantidad: $cantidad) al carrito $idCarrito');

      final response = await http.post(
        Uri.parse('$_baseUrl/$idCarrito/productos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id_producto': idProducto, 'cantidad': cantidad}),
      );

      print('Respuesta: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Error al agregar producto al carrito: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error completo al agregar producto: $e');
      throw Exception('Error al agregar producto: $e');
    }
  }

  // Update item quantity
  Future<void> actualizarCantidadDetalle(
      int idCarrito, int idProducto, int nuevaCantidad) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$idCarrito/productos/$idProducto'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'cantidad': nuevaCantidad}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar cantidad: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar cantidad: $e');
    }
  }

  // Remove item from cart
  Future<void> eliminarDetalleCarrito(int idCarrito, int idProducto) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$idCarrito/productos/$idProducto'),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  // Process purchase/checkout
  Future<void> procesarCompra(int idCarrito) async {
    try {
      // Por ahora solo vaciar el carrito, implementar lógica de compra después
      final response = await http.delete(
        Uri.parse('$_baseUrl/$idCarrito/productos'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error al procesar compra: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al procesar compra: $e');
    }
  }
}
