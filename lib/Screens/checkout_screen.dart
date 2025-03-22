import 'package:flutter/material.dart';
import '../Models/carrito_model.dart';
import '../Models/cliente_model.dart';
import '../services/carrito_services.dart';
import '../services/compra_services.dart';
import '../store/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  final Carrito carrito;

  const CheckoutScreen({super.key, required this.carrito});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  String _metodoPago = 'Efectivo';
  final _referenciaController = TextEditingController();
  final _notasController = TextEditingController();
  bool _procesando = false;
  String _errorMessage = '';

  final CompraService _compraService = CompraService();
  final CarritoService _carritoService = CarritoService();

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _referenciaController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _procesarCompra() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _procesando = true;
      _errorMessage = '';
    });

    try {
      // Crear objeto cliente
      final cliente = Cliente(
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        email: _emailController.text,
        direccion: _direccionController.text,
        telefono: _telefonoController.text,
      );

      // Llamar al servicio para procesar la compra
      await _compraService.procesarCompra(
        cliente: cliente,
        carrito: widget.carrito,
        metodoPago: _metodoPago,
        referenciaPago: _referenciaController.text,
        notas: _notasController.text,
      );

      // Vaciar el carrito después de procesar la compra
      await _carritoService.procesarCompra(widget.carrito.idCarrito);

      // Mostrar mensaje de éxito y volver a la pantalla anterior
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Tu pedido ha sido registrado con éxito.\n'
              'Muy pronto nos pondremos en contacto contigo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Navegar dos veces hacia atrás (checkout -> carrito -> home)
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al procesar la compra: $e';
        _procesando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si hay productos en el carrito
    final hasProducts = widget.carrito.carritoProductos != null &&
        widget.carrito.carritoProductos!.isNotEmpty;

    // Mostrar cantidad de productos para depuración
    print('Checkout - ID Carrito: ${widget.carrito.idCarrito}');
    print('Checkout - Total: ${widget.carrito.total}');
    print(
        'Checkout - Productos: ${widget.carrito.carritoProductos?.length ?? 0}');

    if (widget.carrito.carritoProductos != null) {
      for (var p in widget.carrito.carritoProductos!) {
        print(
            'Checkout - Producto: ID=${p.idProducto}, Cantidad=${p.cantidad}');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos de Envío'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _procesando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sección de datos personales
                    const Text(
                      'Datos Personales',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nombre
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Apellido
                    TextFormField(
                      controller: _apellidoController,
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu apellido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Por favor ingresa un email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Teléfono
                    TextFormField(
                      controller: _telefonoController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu teléfono';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Dirección
                    TextFormField(
                      controller: _direccionController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu dirección';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Sección de métodos de pago
                    const Text(
                      'Método de Pago',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Radio buttons para método de pago
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Efectivo'),
                            value: 'Efectivo',
                            groupValue: _metodoPago,
                            onChanged: (value) {
                              setState(() {
                                _metodoPago = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Transferencia'),
                            value: 'Transferencia',
                            groupValue: _metodoPago,
                            onChanged: (value) {
                              setState(() {
                                _metodoPago = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Referencia (solo visible si es transferencia)
                    if (_metodoPago == 'Transferencia')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _referenciaController,
                            decoration: const InputDecoration(
                              labelText: 'Referencia de pago',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.payment),
                            ),
                            validator: (value) {
                              if (_metodoPago == 'Transferencia' &&
                                  (value == null || value.isEmpty)) {
                                return 'Por favor ingresa la referencia de pago';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),

                    // Notas adicionales
                    /*TextFormField(
                      controller: _notasController,
                      decoration: const InputDecoration(
                        labelText: 'Notas adicionales (opcional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),*/

                    // Información del pedido
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Resumen del Pedido',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total:'),
                                Text(
                                  'LPS. ${widget.carrito.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Productos: ${widget.carrito.carritoProductos?.length ?? 0}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Mensaje de error
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Botón de procesar compra
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _procesando ? null : _procesarCompra,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Confirmar Compra',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
