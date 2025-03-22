class Cliente {
  final int idCliente;
  final String nombre;
  final String? apellido;
  final String? email;
  final String? telefono;
  final String? direccion;
 
  
  Cliente({
    required this.idCliente,
    required this.nombre,
    this.apellido,
    this.email,
    this.telefono,
    this.direccion,
 
  });
  
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['id_cliente'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      telefono: json['telefono'],
      direccion: json['direccion'],
 
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id_cliente': idCliente,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
 
    };
  }
}