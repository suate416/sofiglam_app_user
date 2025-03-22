
import 'productos_model.dart';

class CompraDetalle {
  final int idDetalle;
  final int cantidad;
  final double precioUnitario;
  final int idCompra;
  final int idProducto;
 
  final Producto? producto;
  
  CompraDetalle({
    required this.idDetalle,
    required this.cantidad,
    required this.precioUnitario,
    required this.idCompra,
    required this.idProducto,
 
    this.producto,
  });
  
  factory CompraDetalle.fromJson(Map<String, dynamic> json) {
    return CompraDetalle(
      idDetalle: json['id_detalle'],
      cantidad: json['cantidad'],
      precioUnitario: double.parse(json['precio_unitario'].toString()),
      idCompra: json['id_compra'],
      idProducto: json['id_producto'],
 
      producto: json['Producto'] != null ? Producto.fromJson(json['Producto']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id_detalle': idDetalle,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'id_compra': idCompra,
      'id_producto': idProducto,
 
    };
  }
}