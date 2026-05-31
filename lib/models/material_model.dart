import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialEstudio {
  final String id;
  final String nombre;
  final String materia;
  final String archivoUrl;
  final String subidoPor;
  final DateTime fecha;

  MaterialEstudio({
    required this.id,
    required this.nombre,
    required this.materia,
    required this.archivoUrl,
    required this.subidoPor,
    required this.fecha,
  });

  factory MaterialEstudio.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MaterialEstudio(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      materia: data['materia'] ?? '',
      archivoUrl: data['archivoUrl'] ?? '',
      subidoPor: data['subidoPor'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
    );
  }
}
