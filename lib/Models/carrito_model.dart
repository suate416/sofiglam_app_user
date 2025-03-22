import 'carrito_producto_model.dart';

class Carrito {
  final int idCarrito;
  final DateTime fechaCreacion;
  final double total;
  final String sesionId;
  final DateTime expiraEn;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CarritoProducto>? carritoProductos;
  
  Carrito({
    required this.idCarrito,
    required this.fechaCreacion,
    required this.total,
    required this.sesionId,
    required this.expiraEn,
    required this.createdAt,
    required this.updatedAt,
    this.carritoProductos,
  });
  
  factory Carrito.fromJson(Map<String, dynamic> json) {
    List<CarritoProducto>? productos;
    if (json['CarritoProductos'] != null) {
      productos = (json['CarritoProductos'] as List)
          .map((producto) => CarritoProducto.fromJson(producto))
          .toList();
    }
    
    return Carrito(
      idCarrito: json['id_carrito'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      total: double.parse(json['total'].toString()),
      sesionId: json['sesion_id'],
      expiraEn: DateTime.parse(json['expira_en']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      carritoProductos: productos,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id_carrito': idCarrito,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'total': total,
      'sesion_id': sesionId,
      'expira_en': expiraEn.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}