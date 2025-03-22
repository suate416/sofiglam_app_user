import 'package:flutter/material.dart';
import '../Models/carrito_model.dart';
import '../Models/carrito_producto_model.dart';
import '../services/carrito_services.dart';
import '../store/app_colors.dart';
import 'checkout_screen.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  _CarritoScreenState createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final CarritoService _carritoService = CarritoService();
  bool _isLoading = true;
  Carrito? _carrito;
  List<CarritoProducto> _productos = [];
  double _subtotal = 0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
  }

  Future<void> _cargarCarrito() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Obtener o crear carrito
      final carrito = await _carritoService.obtenerCrearCarrito();

      if (mounted) {
        setState(() {
          _carrito = carrito;
        });
      }

      // Obtener detalles del carrito
      if (_carrito != null) {
        final carritoConDetalles =
            await _carritoService.obtenerCarritoConDetalles();

        // Información de depuración
        print('### INFO DEL CARRITO ###');
        print('ID Carrito: ${carritoConDetalles.idCarrito}');
        print('Subtotal: ${carritoConDetalles.total}');
        print(
            'Cantidad de productos: ${carritoConDetalles.carritoProductos?.length ?? 0}');

        if (carritoConDetalles.carritoProductos != null) {
          for (var producto in carritoConDetalles.carritoProductos!) {
            print(
                'Producto en carrito: ID=${producto.idProducto}, Cantidad=${producto.cantidad}');
            print(
                'Información del producto: ${producto.producto?.nombre ?? "Sin nombre"}, Precio=${producto.precioUnitario}');
          }
        }

        if (mounted) {
          setState(() {
            _productos = carritoConDetalles.carritoProductos ?? [];
            _subtotal = carritoConDetalles.total;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('ERROR CARGANDO CARRITO: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar el carrito: $e';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el carrito: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _actualizarCantidad(int idProducto, int nuevaCantidad) async {
    try {
      if (_carrito == null) return;
      await _carritoService.actualizarCantidadDetalle(
          _carrito!.idCarrito, idProducto, nuevaCantidad);
      _cargarCarrito(); // Recargar carrito después de actualizar
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al actualizar cantidad: $e';
      });
    }
  }

  Future<void> _eliminarProducto(int idProducto) async {
    try {
      if (_carrito == null) return;
      await _carritoService.eliminarDetalleCarrito(
          _carrito!.idCarrito, idProducto);
      _cargarCarrito(); // Recargar carrito después de eliminar
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al eliminar producto: $e';
      });
    }
  }

  Future<void> _procesarCompra() async {
    if (_carrito == null || _productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay productos en el carrito'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Crear un nuevo carrito con los productos actuales
      final carritoCompleto = Carrito(
        idCarrito: _carrito!.idCarrito,
        fechaCreacion: _carrito!.fechaCreacion,
        total: _subtotal,
        sesionId: _carrito!.sesionId,
        expiraEn: _carrito!.expiraEn,
        createdAt: _carrito!.createdAt,
        updatedAt: _carrito!.updatedAt,
        carritoProductos: List<CarritoProducto>.from(_productos),
      );

      print('Procesando compra:');
      print('Carrito ID: ${carritoCompleto.idCarrito}');
      print('Subtotal: ${carritoCompleto.total}');
      print('Productos: ${carritoCompleto.carritoProductos?.length ?? 0}');

      // Navegar a la pantalla de checkout
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(carrito: carritoCompleto),
        ),
      )
          .then((_) {
        // Cuando regrese, recargar el carrito
        _cargarCarrito();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al procesar la compra: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar la compra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarCarrito,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Lo sentimos, ocurrió un error',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _cargarCarrito,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Intentar de nuevo'),
                      ),
                    ],
                  ),
                )
              : _productos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tu carrito está vacío',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Agrega productos para comenzar',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Text('Ir a comprar'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: _productos.length,
                            itemBuilder: (context, index) {
                              final producto = _productos[index];
                              return Card(
                                margin: const EdgeInsets.all(8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      // Imagen del producto
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1,
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(producto
                                                    .producto?.file ??
                                                'https://via.placeholder.com/80'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Información del producto
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              producto.producto?.nombre ??
                                                  'Producto #${producto.idProducto}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'LPS. ${producto.precioUnitario.toStringAsFixed(2)} c/u',
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons
                                                                .remove_circle_outline,
                                                            size: 20,
                                                            color: AppColors
                                                                .primary),
                                                        onPressed: () {
                                                          if (producto
                                                                  .cantidad >
                                                              1) {
                                                            _actualizarCantidad(
                                                              producto
                                                                  .idProducto,
                                                              producto.cantidad -
                                                                  1,
                                                            );
                                                          }
                                                        },
                                                        constraints:
                                                            BoxConstraints
                                                                .tight(const Size(
                                                                    30, 30)),
                                                        padding:
                                                            EdgeInsets.zero,
                                                      ),
                                                      Text(
                                                        '${producto.cantidad}',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons
                                                                .add_circle_outline,
                                                            size: 20,
                                                            color: AppColors
                                                                .primary),
                                                        onPressed: () {
                                                          _actualizarCantidad(
                                                            producto.idProducto,
                                                            producto.cantidad +
                                                                1,
                                                          );
                                                        },
                                                        constraints:
                                                            BoxConstraints
                                                                .tight(const Size(
                                                                    30, 30)),
                                                        padding:
                                                            EdgeInsets.zero,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  'LPS. ${(producto.precioUnitario * producto.cantidad).toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Botón eliminar
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () => _eliminarProducto(
                                            producto.idProducto),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Resumen y botón de compra
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, -3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Subtotal:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'LPS. ${_subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _procesarCompra,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Proceder al Pago',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}
