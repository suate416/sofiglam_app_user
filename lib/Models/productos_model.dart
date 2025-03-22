import 'categoria_model.dart';

class Producto {
  final int idProducto;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;
  final String genero;
  final String material;
  final String file;
  final int idCategoria;
 
  final Categoria categoria;
  
  Producto({
    required this.idProducto,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.genero,
    required this.material,
    required this.file,
    required this.idCategoria,
 
   required this.categoria,
  });
  
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: json['id_producto'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: double.parse(json['precio'].toString()),
      stock: json['stock'],
      genero: json['genero'],
      material: json['material'],
      file: json['file'],
      idCategoria: json['id_categoria'],
 
      categoria: Categoria.fromJson(json['Categoria']!),

    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id_producto': idProducto,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
      'genero': genero,
      'material': material,
      'file': file,
      'id_categoria': idCategoria,
 
    };
  }
}