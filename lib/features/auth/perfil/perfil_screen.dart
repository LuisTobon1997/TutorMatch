import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  Map<String, dynamic>? userData;

  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  String? _carreraSeleccionada;
  String? _semestreSeleccionado;
  DateTime? _fechaNacimiento;

  Uint8List? _imagenLocalBytes;

  final List<String> _carreras = [
    'Ingeniería Informática',
    'Administración de Empresas',
    'Contaduría Pública',
    'Diseño Visual',
    'Seguridad y Salud en el Trabajo',
  ];
  final List<String> _semestres = List.generate(10, (i) => "Semestre ${i + 1}");

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    if (currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        userData = doc.data();
        _nombreController.text = userData?['nombre'] ?? '';
        _cedulaController.text = userData?['cedula'] ?? '';
        _carreraSeleccionada = userData?['carrera'];
        _semestreSeleccionado = userData?['semestre'];

        if (userData?['fechaNacimiento'] != null) {
          _fechaNacimiento = (userData?['fechaNacimiento'] as Timestamp)
              .toDate();
        }
      } else {
        _nombreController.text = currentUser!.displayName ?? '';
        _isEditing = true;
        _mostrarSnack('Por favor completa tu perfil', Colors.orange);
      }
    } catch (e) {
      _mostrarSnack('Error al cargar perfil: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? seleccionado = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'CO'),
    );
    if (seleccionado != null && seleccionado != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = seleccionado;
      });
    }
  }

  Future<void> _subirFotoPerfil() async {
    try {
      FilePickerResult? resultado = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (resultado != null) {
        setState(() {
          _isSaving = true;
          _imagenLocalBytes = resultado.files.first.bytes;
        });

        String nombreFinal =
            "perfil_${currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";
        Reference ref = FirebaseStorage.instance.ref().child(
          'perfiles/$nombreFinal',
        );

        await ref.putData(resultado.files.first.bytes!);
        String urlDescarga = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .set({'fotoUrl': urlDescarga}, SetOptions(merge: true));

        setState(() {
          userData ??= {};
          userData!['fotoUrl'] = urlDescarga;
          _isSaving = false;
        });

        _mostrarSnack('Foto actualizada exitosamente', Colors.green);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      _mostrarSnack('Error al subir foto: $e', Colors.red);
    }
  }

  Future<void> _guardarCambios() async {
    final String cedulaLimpia = _cedulaController.text.trim();
    final String nombreLimpio = _nombreController.text.trim();

    if (_carreraSeleccionada == null ||
        _semestreSeleccionado == null ||
        cedulaLimpia.isEmpty ||
        nombreLimpio.isEmpty ||
        _fechaNacimiento == null) {
      _mostrarSnack('Todos los campos son obligatorios', Colors.orange);
      return;
    }

    final RegExp cedulaRegExp = RegExp(r'^[0-9]{7,10}$');
    if (!cedulaRegExp.hasMatch(cedulaLimpia)) {
      _mostrarSnack(
        'Por favor ingresa una Cédula válida (7 a 10 números)',
        Colors.red,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final queryCedula = await FirebaseFirestore.instance
          .collection('users')
          .where('cedula', isEqualTo: cedulaLimpia)
          .get();

      if (queryCedula.docs.isNotEmpty &&
          queryCedula.docs.first.id != currentUser!.uid) {
        _mostrarSnack(
          'Esta cédula ya se encuentra registrada por otro estudiante',
          Colors.red,
        );
        setState(() => _isSaving = false);
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .set({
            'nombre': nombreLimpio,
            'cedula': cedulaLimpia,
            'carrera': _carreraSeleccionada,
            'semestre': _semestreSeleccionado,
            'fechaNacimiento': _fechaNacimiento,
          }, SetOptions(merge: true));

      await currentUser!.updateDisplayName(nombreLimpio);

      _mostrarSnack('Perfil actualizado correctamente', Colors.green);

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
    } catch (e) {
      _mostrarSnack('Error al guardar: $e', Colors.red);
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _mostrarSnack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Widget _buildFormulario(Color primaryBlue, String fechaTexto) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      shadowColor: Colors.black12,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 55),
                ],
              ),

              Positioned(
                bottom: 0,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 58,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _imagenLocalBytes != null
                            ? MemoryImage(_imagenLocalBytes!) as ImageProvider
                            : (userData?['fotoUrl'] != null
                                  ? NetworkImage(userData!['fotoUrl'])
                                  : null),
                        child:
                            (_imagenLocalBytes == null &&
                                userData?['fotoUrl'] == null)
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    if (_isEditing)
                      CircleAvatar(
                        backgroundColor: const Color(0xFFFFCA28),
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.black87,
                            size: 18,
                          ),
                          onPressed: _isSaving ? null : _subirFotoPerfil,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
            child: Column(
              children: [
                TextField(
                  controller: _nombreController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(
                    labelText: 'Nombre Completo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _cedulaController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cédula de Ciudadanía',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    hintText: 'Ej: 1121949513',
                  ),
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: _isEditing ? () => _seleccionarFecha(context) : null,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Nacimiento (Validación)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      prefixIcon: Icon(Icons.calendar_today_rounded, size: 20),
                    ),
                    child: Text(
                      fechaTexto,
                      style: TextStyle(
                        fontSize: 16,
                        color: _fechaNacimiento == null
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Divider(),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Información Académica",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _isEditing ? primaryBlue : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Carrera',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  initialValue: _carreraSeleccionada,
                  items: _carreras
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: _isEditing
                      ? (v) => setState(() => _carreraSeleccionada = v)
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Semestre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  initialValue: _semestreSeleccionado,
                  items: _semestres
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: _isEditing
                      ? (v) => setState(() => _semestreSeleccionado = v)
                      : null,
                ),
                const SizedBox(height: 30),

                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _guardarCambios,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'GUARDAR CAMBIOS',
                              style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildCalificaciones(Color primaryBlue) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFCA28),
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  "Mis Reconocimientos",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Lo que dicen tus compañeros sobre los recursos que has compartido.",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('materiales')
                  .where('userId', isEqualTo: currentUser?.uid)
                  .snapshots(),
              builder: (context, materialSnapshot) {
                if (materialSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final listaMateriales = materialSnapshot.data?.docs ?? [];
                if (listaMateriales.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.library_books_rounded,
                            size: 60,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Aún no has subido recursos.",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listaMateriales.length,
                  itemBuilder: (context, idx) {
                    final matDoc = listaMateriales[idx];
                    final matData = matDoc.data() as Map<String, dynamic>;
                    final String matTitulo = matData['titulo'] ?? 'Sin título';

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('materiales')
                          .doc(matDoc.id)
                          .collection('comentarios')
                          .orderBy('fecha', descending: true)
                          .snapshots(),
                      builder: (context, commentSnapshot) {
                        final comentarios = commentSnapshot.data?.docs ?? [];
                        if (comentarios.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ExpansionTile(
                            shape: const RoundedRectangleBorder(
                              side: BorderSide.none,
                            ),
                            title: Text(
                              matTitulo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              "${matData['asignatura'] ?? 'General'} • (${comentarios.length} valoraciones)",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.blueGrey,
                              ),
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryBlue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.insert_drive_file_rounded,
                                color: primaryBlue,
                              ),
                            ),
                            children: comentarios.map((cDoc) {
                              final cData = cDoc.data() as Map<String, dynamic>;
                              final int stars = cData['puntuacion'] ?? 0;
                              final String commentText =
                                  cData['comentario'] ?? '';
                              final String reviewer =
                                  cData['usuarioNombre'] ?? 'Estudiante';

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.black12),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.grey[300],
                                      child: const Icon(
                                        Icons.person,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                reviewer,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Row(
                                                children: List.generate(
                                                  5,
                                                  (starIdx) => Icon(
                                                    starIdx < stars
                                                        ? Icons.star_rounded
                                                        : Icons
                                                              .star_border_rounded,
                                                    color: const Color(
                                                      0xFFFFCA28,
                                                    ),
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          commentText.isNotEmpty
                                              ? Text(
                                                  '"$commentText"',
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.grey[800],
                                                    fontSize: 13,
                                                  ),
                                                )
                                              : Text(
                                                  'Valoró sin comentario.',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1565C0);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 900;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryBlue)),
      );
    }

    String fechaTexto = _fechaNacimiento != null
        ? "${_fechaNacimiento!.day.toString().padLeft(2, '0')}/${_fechaNacimiento!.month.toString().padLeft(2, '0')}/${_fechaNacimiento!.year}"
        : 'Seleccionar fecha';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),

      appBar: AppBar(
        title: const Text('Mi Perfil AUNAR'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_rounded),
            tooltip: _isEditing ? 'Cancelar edición' : 'Editar información',
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _cargarDatosUsuario();
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildFormulario(primaryBlue, fechaTexto),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        flex: 4,
                        child: _buildCalificaciones(primaryBlue),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildFormulario(primaryBlue, fechaTexto),
                      const SizedBox(height: 24),
                      _buildCalificaciones(primaryBlue),
                      const SizedBox(height: 40),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
