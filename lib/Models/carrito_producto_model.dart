import 'productos_model.dart';

class CarritoProducto {
  final int id;
  final int idProducto;
  final int cantidad;
  final double precioUnitario;
  final int idCarrito;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Producto? producto;
  
  CarritoProducto({
    required this.id,
    required this.idProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.idCarrito,
    required this.createdAt,
    required this.updatedAt,
    this.producto,
  });
  
  factory CarritoProducto.fromJson(Map<String, dynamic> json) {
    return CarritoProducto(
      id: json['id'],
      idProducto: json['id_producto'],
      cantidad: json['cantidad'],
      precioUnitario: double.parse(json['precio_unitario'].toString()),
      idCarrito: json['id_carrito'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      producto: json['Producto'] != null ? Producto.fromJson(json['Producto']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_producto': idProducto,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'id_carrito': idCarrito,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}