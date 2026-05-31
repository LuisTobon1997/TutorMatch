import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'subir_material_screen.dart';
import 'programar_tutoria_screen.dart';
import '../auth/perfil/perfil_screen.dart';
import '../auth/login_screen.dart';
import 'sala_envivo_screen.dart';

const Color kPrimaryBlue = Color(0xFF1565C0);
const Color kAccentGold = Color(0xFFFFCA28);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _carreraSeleccionada;
  String? _semestreSeleccionado;
  String? _userRole;

  final List<Map<String, dynamic>> _carreras = [
    {'nombre': 'Ingeniería Informática', 'icon': Icons.code},
    {'nombre': 'Administración de Empresas', 'icon': Icons.business},
    {'nombre': 'Contaduría Pública', 'icon': Icons.account_balance},
    {'nombre': 'Diseño Visual', 'icon': Icons.palette},
    {
      'nombre': 'Seguridad y Salud en el Trabajo',
      'icon': Icons.health_and_safety,
    },
  ];

  final List<String> _semestres = List.generate(10, (i) => "Semestre ${i + 1}");

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _userRole = doc.data()?['rol'] as String?;
        });
      }
    }
  }

  Future<void> _abrirDocumento(String? url) async {
    if (url == null) {
      return;
    }
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      debugPrint("Error al abrir URL");
    }
  }

  Future<void> _mostrarPerfilAutor(
    String? autorId,
    String materia,
    String docId,
    String docTitulo,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final miUid = currentUser?.uid;
    final miNombre = currentUser?.displayName ?? 'Un compañero';

    if (autorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil no disponible.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (autorId == miUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes valorarte a ti mismo 😉'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    final comentarioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        int estrellasSeleccionadas = 0;
        bool cargando = true;
        Map<String, dynamic>? datosAutor;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            if (cargando) {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(autorId)
                  .get()
                  .then((doc) {
                    if (doc.exists) {
                      datosAutor = doc.data();
                    }
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(autorId)
                        .collection('valoraciones')
                        .doc(miUid)
                        .get()
                        .then((votoDoc) {
                          if (votoDoc.exists) {
                            estrellasSeleccionadas =
                                votoDoc.data()?['puntuacion'] ?? 0;
                            comentarioController.text =
                                votoDoc.data()?['comentario'] ?? '';
                          }
                          setStateDialog(() => cargando = false);
                        });
                  });
            }

            if (cargando) {
              return const AlertDialog(
                content: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (datosAutor == null) {
              return const AlertDialog(
                content: Text("Usuario no encontrado en la base de datos."),
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Perfil del Autor',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kPrimaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: datosAutor!['fotoUrl'] != null
                          ? NetworkImage(datosAutor!['fotoUrl'])
                          : null,
                      child: datosAutor!['fotoUrl'] == null
                          ? const Icon(
                              Icons.person,
                              size: 45,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      datosAutor!['nombre'] ?? 'Estudiante',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${datosAutor!['carrera']}",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "${datosAutor!['semestre']}",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(),
                    ),
                    const Text(
                      '¿Qué tan útil fue su material?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < estrellasSeleccionadas
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: kAccentGold,
                            size: 38,
                          ),
                          onPressed: () => setStateDialog(
                            () => estrellasSeleccionadas = index + 1,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: comentarioController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Deja un comentario (Opcional)',
                        border: OutlineInputBorder(),
                        hintText: '¡Excelente material, gracias!',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: estrellasSeleccionadas == 0
                      ? null
                      : () async {
                          final comentarioTexto = comentarioController.text
                              .trim();
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(autorId)
                              .collection('valoraciones')
                              .doc(miUid)
                              .set({
                                'puntuacion': estrellasSeleccionadas,
                                'comentario': comentarioTexto,
                                'fecha': FieldValue.serverTimestamp(),
                              });
                          await FirebaseFirestore.instance
                              .collection('materiales')
                              .doc(docId)
                              .collection('comentarios')
                              .doc(miUid)
                              .set({
                                'usuarioId': miUid,
                                'usuarioNombre': miNombre,
                                'puntuacion': estrellasSeleccionadas,
                                'comentario': comentarioTexto,
                                'fecha': FieldValue.serverTimestamp(),
                                'documentoTitulo': docTitulo,
                              });
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(autorId)
                              .collection('notificaciones')
                              .add({
                                'remitenteNombre': miNombre,
                                'puntuacion': estrellasSeleccionadas,
                                'materia': materia,
                                'comentario': comentarioTexto,
                                'fecha': FieldValue.serverTimestamp(),
                                'leida': false,
                              });
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '¡Gracias por calificar el aporte!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  child: const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarNotificaciones() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PanelNotificacionesUI(),
    );
  }

  Widget _buildCampanaNotificaciones() {
    final miUid = FirebaseAuth.instance.currentUser?.uid;
    if (miUid == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(miUid)
          .collection('notificaciones')
          .where('leida', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final int noLeidas = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_rounded),
              tooltip: 'Notificaciones',
              onPressed: _mostrarNotificaciones,
            ),
            if (noLeidas > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    noLeidas > 9 ? '9+' : noLeidas.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSidebar(bool isDesktop) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kPrimaryBlue,
            borderRadius: isDesktop
                ? const BorderRadius.vertical(top: Radius.circular(20))
                : null,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.menu_book_rounded, color: Colors.white, size: 32),
              SizedBox(height: 10),
              Text(
                "Biblioteca AUNAR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Explora por programa",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: _carreras.map((c) {
              final bool isCarreraSeleccionada =
                  _carreraSeleccionada == c['nombre'];
              return ExpansionTile(
                leading: Icon(
                  c['icon'] as IconData,
                  color: isCarreraSeleccionada
                      ? kPrimaryBlue
                      : Colors.grey[700],
                ),
                title: Text(
                  c['nombre'] as String,
                  style: TextStyle(
                    fontWeight: isCarreraSeleccionada
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isCarreraSeleccionada
                        ? kPrimaryBlue
                        : Colors.black87,
                  ),
                ),
                initiallyExpanded: isCarreraSeleccionada,
                children: _semestres.map((s) {
                  final bool isSelected =
                      isCarreraSeleccionada && _semestreSeleccionado == s;
                  return ListTile(
                    contentPadding: const EdgeInsets.only(left: 54, right: 16),
                    title: Text(
                      s,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? kPrimaryBlue : Colors.black87,
                      ),
                    ),
                    tileColor: isSelected
                        ? kPrimaryBlue.withValues(alpha: 0.1)
                        : Colors.transparent,
                    onTap: () {
                      setState(() {
                        _carreraSeleccionada = c['nombre'] as String;
                        _semestreSeleccionado = s;
                      });
                      if (!isDesktop) {
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (_carreraSeleccionada == null || _semestreSeleccionado == null) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.dashboard_customize_rounded,
                  size: 100,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 24),
                const Text(
                  "¡Bienvenido al Repositorio!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Selecciona un programa y un semestre en el menú lateral para empezar a explorar y descargar el material de estudio compartido por tu comunidad.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            "$_carreraSeleccionada / $_semestreSeleccionado",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kPrimaryBlue,
            ),
          ),
        ),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tutorias_en_vivo')
              .where('carrera', isEqualTo: _carreraSeleccionada)
              .where('semestre', isEqualTo: _semestreSeleccionado)
              .where('estado', isEqualTo: 'programada')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.podcasts_rounded, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text(
                      "Tutorías Próximas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 165,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final tutoria = doc.data() as Map<String, dynamic>;
                      final fechaObj = (tutoria['fechaProgramada'] as Timestamp)
                          .toDate();

                      final String docenteId = tutoria['docenteId'] ?? '';
                      final bool esElProfesor = currentUserUid == docenteId;

                      final List<dynamic> participantesDin =
                          tutoria['participantes'] ?? [];
                      final List<String> participantes = participantesDin
                          .cast<String>();
                      final bool estaInscrito = participantes.contains(
                        currentUserUid,
                      );
                      final int cantidadParticipantes = participantes.length;

                      return Container(
                        width: 320,
                        margin: const EdgeInsets.only(right: 15),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kPrimaryBlue, Color(0xFF1976D2)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    tutoria['titulo'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (esElProfesor)
                                  InkWell(
                                    onTap: () async {
                                      final bool?
                                      confirmar = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('¿Cancelar clase?'),
                                          content: const Text(
                                            'Esta acción eliminará la tutoría programada.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Volver'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text(
                                                'Cancelar Clase',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmar == true) {
                                        await FirebaseFirestore.instance
                                            .collection('tutorias_en_vivo')
                                            .doc(doc.id)
                                            .delete();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('Clase cancelada'),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: const Icon(
                                      Icons.cancel_rounded,
                                      color: Colors.redAccent,
                                      size: 22,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Prof. ${tutoria['docenteNombre']}",
                              style: const TextStyle(
                                color: kAccentGold,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Materia: ${tutoria['materia']}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const Spacer(),

                            Row(
                              children: [
                                const Icon(
                                  Icons.people_alt_rounded,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "$cantidadParticipantes estudiantes inscritos",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_filled_rounded,
                                      color: kAccentGold,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${fechaObj.day}/${fechaObj.month} - ${fechaObj.hour}:${fechaObj.minute.toString().padLeft(2, '0')}",
                                      style: const TextStyle(
                                        color: kAccentGold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (esElProfesor)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 0,
                                      ),
                                      minimumSize: const Size(80, 30),
                                    ),
                                    icon: const Icon(
                                      Icons.videocam_rounded,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      "INICIAR EN VIVO",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SalaEnvivoScreen(
                                                liveID: doc.id,
                                                isHost: true,
                                                userId:
                                                    currentUserUid ??
                                                    'profe_desc',
                                                userName:
                                                    FirebaseAuth
                                                        .instance
                                                        .currentUser
                                                        ?.displayName ??
                                                    'Profesor',
                                              ),
                                        ),
                                      );
                                    },
                                  )
                                else if (estaInscrito)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 0,
                                      ),
                                      minimumSize: const Size(80, 30),
                                    ),
                                    icon: const Icon(
                                      Icons.login_rounded,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      "ENTRAR A SALA",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SalaEnvivoScreen(
                                                liveID: doc.id,
                                                isHost: false,
                                                userId:
                                                    currentUserUid ??
                                                    'estud_desc',
                                                userName:
                                                    FirebaseAuth
                                                        .instance
                                                        .currentUser
                                                        ?.displayName ??
                                                    'Estudiante',
                                              ),
                                        ),
                                      );
                                    },
                                  )
                                else
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: kPrimaryBlue,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 0,
                                      ),
                                      minimumSize: const Size(80, 30),
                                    ),
                                    onPressed: () async {
                                      if (currentUserUid == null) {
                                        return;
                                      }
                                      await FirebaseFirestore.instance
                                          .collection('tutorias_en_vivo')
                                          .doc(doc.id)
                                          .update({
                                            'participantes':
                                                FieldValue.arrayUnion([
                                                  currentUserUid,
                                                ]),
                                          });
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              '¡Te has inscrito a la clase!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      "INSCRIBIRSE",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 30),
              ],
            );
          },
        ),

        const Text(
          "Material de Estudio Compartido",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('materiales')
                .where('carrera', isEqualTo: _carreraSeleccionada)
                .where('semestre', isEqualTo: _semestreSeleccionado)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_off_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No hay archivos en este semestre aún.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const Text(
                        "¡Sé el primero en subir uno!",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, i) {
                  final doc = snapshot.data!.docs[i];
                  final data = doc.data() as Map<String, dynamic>;
                  final bool esPropietario =
                      data['userId'] == FirebaseAuth.instance.currentUser?.uid;
                  String fechaTexto = 'Sin fecha';
                  if (data['fecha'] != null && data['fecha'] is Timestamp) {
                    final DateTime f = (data['fecha'] as Timestamp).toDate();
                    fechaTexto =
                        "${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}";
                  }

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: kPrimaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: kPrimaryBlue,
                                ),
                              ),
                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['titulo'] ?? 'Archivo',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Materia: ${data['asignatura']}",
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Subido el: $fechaTexto",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () => _mostrarPerfilAutor(
                                        data['userId'],
                                        data['asignatura'] ?? 'tu recurso',
                                        doc.id,
                                        data['titulo'] ?? 'Archivo',
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.person_pin,
                                            size: 16,
                                            color: kPrimaryBlue,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              "Autor: ${data['autor']}",
                                              style: const TextStyle(
                                                color: kPrimaryBlue,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (esPropietario) ...[
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                  ),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                  ),
                                  label: const Text("ELIMINAR"),
                                  onPressed: () async {
                                    final bool?
                                    confirmar = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('¿Eliminar archivo?'),
                                        content: const Text(
                                          'Esta acción borrará el recurso permanentemente.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text(
                                              'Eliminar',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmar == true) {
                                      await FirebaseFirestore.instance
                                          .collection('materiales')
                                          .doc(doc.id)
                                          .delete();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Archivo eliminado'),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                                const Spacer(),
                              ],

                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.download_rounded,
                                  size: 18,
                                ),
                                label: const Text("VER DOCUMENTO"),
                                onPressed: () =>
                                    _abrirDocumento(data['archivoUrl']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'TutorMatch - Repositorio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          _buildCampanaNotificaciones(),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Mi Perfil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PerfilScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: isDesktop
          ? null
          : Drawer(child: SafeArea(child: _buildSidebar(false))),
      body: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 320,
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildSidebar(true),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 24,
                      right: 24,
                      bottom: 24,
                    ),
                    child: _buildMainContent(),
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildMainContent(),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_userRole == 'docente') ...[
            FloatingActionButton.extended(
              heroTag: 'btnTutor',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProgramarTutoriaScreen(),
                ),
              ),
              label: const Text(
                'PROGRAMAR TUTORÍA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              icon: const Icon(Icons.video_call_rounded, color: Colors.white),
              backgroundColor: Colors.redAccent,
            ),
            const SizedBox(height: 16),
          ],
          FloatingActionButton.extended(
            heroTag: 'btnMaterial',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubirMaterialScreen()),
            ),
            label: const Text(
              'SUBIR MATERIAL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.black87),
            backgroundColor: kAccentGold,
          ),
        ],
      ),
    );
  }
}

class PanelNotificacionesUI extends StatefulWidget {
  const PanelNotificacionesUI({super.key});
  @override
  State<PanelNotificacionesUI> createState() => _PanelNotificacionesUIState();
}

class _PanelNotificacionesUIState extends State<PanelNotificacionesUI> {
  bool _mostrarSoloNoLeidas = false;

  String _obtenerTiempoTranscurrido(DateTime fecha) {
    final diferencia = DateTime.now().difference(fecha);
    if (diferencia.inDays > 7) {
      return '${(diferencia.inDays / 7).floor()} sem';
    }
    if (diferencia.inDays > 0) {
      return '${diferencia.inDays} d';
    }
    if (diferencia.inHours > 0) {
      return '${diferencia.inHours} h';
    }
    if (diferencia.inMinutes > 0) {
      return '${diferencia.inMinutes} min';
    }
    return 'Ahora';
  }

  @override
  Widget build(BuildContext context) {
    final miUid = FirebaseAuth.instance.currentUser?.uid;
    if (miUid == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 15,
              left: 20,
              right: 10,
              bottom: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notificaciones',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_mostrarSoloNoLeidas
                        ? kPrimaryBlue
                        : Colors.grey[200],
                    foregroundColor: !_mostrarSoloNoLeidas
                        ? Colors.white
                        : Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => setState(() => _mostrarSoloNoLeidas = false),
                  child: const Text('Todas'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mostrarSoloNoLeidas
                        ? kPrimaryBlue
                        : Colors.grey[200],
                    foregroundColor: _mostrarSoloNoLeidas
                        ? Colors.white
                        : Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => setState(() => _mostrarSoloNoLeidas = true),
                  child: const Text('No leídas'),
                ),
              ],
            ),
          ),
          const Divider(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(miUid)
                  .collection('notificaciones')
                  .orderBy('fecha', descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var docs = snapshot.data?.docs ?? [];
                if (_mostrarSoloNoLeidas) {
                  docs = docs.where((doc) => doc['leida'] == false).toList();
                }
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay notificaciones',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    final bool esLeida = data['leida'] ?? true;
                    String tiempoTexto = '';
                    if (data['fecha'] != null && data['fecha'] is Timestamp) {
                      tiempoTexto = _obtenerTiempoTranscurrido(
                        (data['fecha'] as Timestamp).toDate(),
                      );
                    }

                    return Dismissible(
                      key: Key(docId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        color: Colors.redAccent,
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      onDismissed: (_) => FirebaseFirestore.instance
                          .collection('users')
                          .doc(miUid)
                          .collection('notificaciones')
                          .doc(docId)
                          .delete(),
                      child: InkWell(
                        onTap: () {
                          if (!esLeida) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(miUid)
                                .collection('notificaciones')
                                .doc(docId)
                                .update({'leida': true});
                          }
                        },
                        child: Container(
                          color: esLeida
                              ? Colors.transparent
                              : kPrimaryBlue.withValues(alpha: 0.05),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.grey[200],
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: kAccentGold,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          height: 1.3,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "${data['remitenteNombre']} ",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: "te ha calificado con ",
                                          ),
                                          TextSpan(
                                            text:
                                                "${data['puntuacion']} estrellas ",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: "en tu recurso de ",
                                          ),
                                          TextSpan(
                                            text:
                                                "${data['materia'] ?? 'AUNAR'}.",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (data['comentario'] != null &&
                                        (data['comentario'] as String)
                                            .isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          '"${data['comentario']}"',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontStyle: FontStyle.italic,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 5),
                                    Text(
                                      tiempoTexto,
                                      style: TextStyle(
                                        color: esLeida
                                            ? Colors.grey
                                            : kPrimaryBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    tooltip: 'Eliminar notificación',
                                    onPressed: () => FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(miUid)
                                        .collection('notificaciones')
                                        .doc(docId)
                                        .delete(),
                                  ),
                                  if (!esLeida)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: kPrimaryBlue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
