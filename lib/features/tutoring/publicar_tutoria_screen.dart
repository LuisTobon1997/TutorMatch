import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'subir_material_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _carreraSeleccionada;

  final List<Map<String, dynamic>> _carreras = [
    {'nombre': 'Ingeniería Informática', 'icon': Icons.code_rounded},
    {
      'nombre': 'Administración de Empresas',
      'icon': Icons.business_center_rounded,
    },
    {
      'nombre': 'Contaduría Pública',
      'icon': Icons.account_balance_wallet_rounded,
    },
    {'nombre': 'Diseño Visual', 'icon': Icons.palette_rounded},
    {
      'nombre': 'Seguridad y Salud en el Trabajo',
      'icon': Icons.health_and_safety_rounded,
    },
  ];

  Future<void> _abrirDocumento(String? url) async {
    if (url == null || url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el documento'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1565C0);
    const Color accentGold = Color(0xFFFFCA28);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          'Repositorio Digital AUNAR',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_carreraSeleccionada != null)
            IconButton(
              icon: const Icon(Icons.grid_view_rounded),
              tooltip: 'Ver todas las carreras',
              onPressed: () => setState(() => _carreraSeleccionada = null),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: _carreraSeleccionada == null
              ? _buildSeleccionCarrera(accentGold, primaryBlue)
              : _buildListaMateriales(primaryBlue),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SubirMaterialScreen()),
        ),
        label: const Text(
          'COMPARTIR RECURSO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add_to_photos_rounded),
        backgroundColor: accentGold,
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildSeleccionCarrera(Color gold, Color blue) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school_rounded, size: 80, color: Color(0xFF1565C0)),
          const SizedBox(height: 16),
          const Text(
            "Bienvenido al Repositorio",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Selecciona tu programa académico para acceder al material.",
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: _carreras.map((carrera) {
              return SizedBox(
                width: 250,
                height: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: blue,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () =>
                      setState(() => _carreraSeleccionada = carrera['nombre']),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(carrera['icon'], size: 40),
                      const SizedBox(height: 12),
                      Text(
                        carrera['nombre'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildListaMateriales(Color blue) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: blue,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => _carreraSeleccionada = null),
              ),
              const SizedBox(width: 10),
              Text(
                "Material de: $_carreraSeleccionada",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('materiales')
                .where('carrera', isEqualTo: _carreraSeleccionada)
                .orderBy('fecha', descending: true)
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
                      const Icon(
                        Icons.search_off_rounded,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text("Aún no hay archivos para $_carreraSeleccionada"),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE3F2FD),
                        child: Icon(
                          Icons.description_rounded,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      title: Text(
                        data['titulo'] ?? 'Sin título',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Materia: ${data['asignatura']}\nSubido por: ${data['autor']}",
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _abrirDocumento(data['archivoUrl']),
                        child: const Text("VER / DESCARGAR"),
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
}
