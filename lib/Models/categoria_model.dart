
import 'dart:convert';

List<Categoria> categoriaFromJson(String str) => List<Categoria>.from(json.decode(str).map((x) => Categoria.fromJson(x)));

String categoriaToJson(List<Categoria> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Categoria {
    int idCategoria;
    String nombre;

    Categoria({
        required this.idCategoria,
        required this.nombre,
    });

    factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        idCategoria: json["id_categoria"] ?? 0, 
        nombre: json["nombre"], 
    );

    Map<String, dynamic> toJson() => {
        "id_categoria": idCategoria,
        "nombre": nombre,
    };
}