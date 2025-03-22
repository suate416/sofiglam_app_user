import 'package:flutter/material.dart';
import '../Models/productos_model.dart';
import '../store/app_colors.dart';
import '../Services/carrito_services.dart';

class ProductoInfoScreen extends StatefulWidget {
  final Producto producto;

  const ProductoInfoScreen({super.key, required this.producto});

  @override
  State<ProductoInfoScreen> createState() => _ProductoInfoScreenState();
}

class _ProductoInfoScreenState extends State<ProductoInfoScreen> {
  int cantidad = 1;
  final CarritoService _carritoService = CarritoService();
  bool isAddingToCart = false;

  void _incrementCantidad() {
    if (cantidad < widget.producto.stock) {
      setState(() {
        cantidad++;
      });
    }
  }

  void _decrementCantidad() {
    if (cantidad > 1) {
      setState(() {
        cantidad--;
      });
    }
  }

  Future<void> _addToCart() async {
    setState(() {
      isAddingToCart = true;
    });

      /*try {
        await _carritoService.agregarProductoAlCarrito(widget.producto.idProducto, cantidad);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto agregado al carrito'),
            backgroundColor: AppColors.primary,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar al carrito: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isAddingToCart = false;
        });
      }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.producto.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.title,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.icons),
          onPressed: () => Navigator.pop(context),
        ),
        
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: Image.network(
                    widget.producto.file,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.producto.categoria.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.producto.nombre,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.title,
                            ),
                          ),
                        ),
                        Text(
                          'LPS. ${widget.producto.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _buildDetailItem(Icons.person_outline,
                            'Genero: ${widget.producto.genero}'),
                        const SizedBox(width: 20),
                        _buildDetailItem(Icons.layers_outlined,
                            'Material: ${widget.producto.material}'),
                      ],
                    ),

                    const SizedBox(height: 12),

                    BuildEnExistenciaWidget(widget.producto.stock),

                    const SizedBox(height: 20),

                    // Descripcion
                    const Text(
                      'Descripcion',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.producto.descripcion,
                      style: const TextStyle(
                        color: AppColors.subtitle,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // Boton de agregar al carrito y seleccion de cantidad
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Selector de cantidad
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: cantidad > 1 ? _decrementCantidad : null,
                        color: AppColors.primary,
                      ),
                      Text(
                        '$cantidad',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: cantidad < widget.producto.stock
                            ? _incrementCantidad
                            : null,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                // Boton agregar al carrito
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.producto.stock > 0
                        ? (isAddingToCart ? null : _addToCart)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isAddingToCart
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'Agregar al Carrito',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.subtitle,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget BuildEnExistenciaWidget(int stock) {
  Color cantidadColor;
  String cantidad;

  if (stock > 10) {
    cantidadColor = Colors.green;
    cantidad = 'En stock: $stock unidades';
  } else if (stock > 5) {
    cantidadColor = Colors.orange;
    cantidad = '¡Solo quedan $stock unidades!';
  } else {
    cantidadColor = Colors.red;
    cantidad = 'Agotado: 0 unidades';
  }

  return Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: cantidadColor,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        cantidad,
        style: TextStyle(
          color: cantidadColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
}