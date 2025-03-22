import 'cliente_model.dart';
import 'compra_detalle.dart';


enum EstadoCompra { Pendiente, Entregado, Cancelado }
enum MetodoPago { Transferencia, Efectivo }

class Compra {
  final int idCompra;
  final DateTime fecha;
  final EstadoCompra estado;
  final double total;
  final MetodoPago metodoPago;
  final String? referenciaPago;
  final String? notas;
  final int idCliente;
 
  final Cliente? cliente;
  final List<CompraDetalle>? detallesCompras;
  
  Compra({
    required this.idCompra,
    required this.fecha,
    required this.estado,
    required this.total,
    required this.metodoPago,
    this.referenciaPago,
    this.notas,
    required this.idCliente,
 
    this.cliente,
    this.detallesCompras,
  });
  
  factory Compra.fromJson(Map<String, dynamic> json) {
    List<CompraDetalle>? detalles;
    if (json['DetallesCompras'] != null) {
      detalles = (json['DetallesCompras'] as List)
          .map((detalle) => CompraDetalle.fromJson(detalle))
          .toList();
    }
    
    return Compra(
      idCompra: json['id_compra'],
      fecha: DateTime.parse(json['fecha']),
      estado: EstadoCompra.values.firstWhere(
        (e) => e.toString() == 'EstadoCompra.${json['estado']}',
        orElse: () => EstadoCompra.Pendiente,
      ),
      total: double.parse(json['total'].toString()),
      metodoPago: MetodoPago.values.firstWhere(
        (e) => e.toString() == 'MetodoPago.${json['metodo_pago']}',
        orElse: () => MetodoPago.Transferencia,
      ),
      referenciaPago: json['referencia_pago'],
      notas: json['notas'],
      idCliente: json['id_cliente'],
 
      cliente: json['Cliente'] != null ? Cliente.fromJson(json['Cliente']) : null,
      detallesCompras: detalles,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id_compra': idCompra,
      'fecha': fecha.toIso8601String(),
      'estado': estado.toString().split('.').last,
      'total': total,
      'metodo_pago': metodoPago.toString().split('.').last,
      'referencia_pago': referenciaPago,
      'notas': notas,
      'id_cliente': idCliente,
 
    };
  }
}