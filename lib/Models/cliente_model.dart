
class Cliente {
  final int? idCliente;
  final String nombre;
  final String apellido;
  final String email;
  final String direccion;
  final String telefono;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cliente({
    this.idCliente,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.direccion,
    required this.telefono,
    this.createdAt,
    this.updatedAt,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['id_cliente'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'] ?? '',
      direccion: json['direccion'],
      telefono: json['telefono'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'direccion': direccion,
      'telefono': telefono,
    };
  }
}