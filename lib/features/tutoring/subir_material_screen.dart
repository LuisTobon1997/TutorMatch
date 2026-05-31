import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubirMaterialScreen extends StatefulWidget {
  const SubirMaterialScreen({super.key});

  @override
  State<SubirMaterialScreen> createState() => _SubirMaterialScreenState();
}

class _SubirMaterialScreenState extends State<SubirMaterialScreen> {
  final _asignaturaManualController = TextEditingController();
  final _tituloController = TextEditingController();
  bool _isLoading = false;
  PlatformFile? _archivoSeleccionado;

  final List<String> _carreras = [
    'Ingeniería Informática',
    'Administración de Empresas',
    'Contaduría Pública',
    'Diseño Visual',
    'Seguridad y Salud en el Trabajo',
  ];

  final List<String> _semestres = List.generate(10, (i) => "Semestre ${i + 1}");

  final Map<String, Map<String, List<String>>> _planDeEstudiosCompleto = {
    'Ingeniería Informática': {
      'Semestre 1': [
        'Conceptos y Métodos Matemáticos',
        'Teoria de La Ingenieria Informatica',
        'Fundamentos de Programación',
        'Sistemas Operativos I',
        'Responsabilidad Ciudadana',
        'Herramientas y Técnicas de Estudio',
      ],
      'Semestre 2': [
        'Lógica Booleana',
        'Cálculo Diferencial',
        'Electromagnetismo',
        'Programación I',
        'Sistemas Operativos II',
        'Introduccion a la Adquisicion de Datos',
        'Taller de Comunicación Oral y Escrita',
        'Inglés A1.1',
      ],
      'Semestre 3': [
        'Cálculo Integral',
        'Álgebra Lineal',
        'Electrónica Analógica',
        'Programación  II',
        'Estructuras de Datos I',
        'Gestion Etrategica y Emprearial',
        'Inglés A1.2',
        'Epistemología de la Investigación',
      ],
      'Semestre 4': [
        'Cálculo Multivariable',
        'Electrónica Digital',
        'Programación III',
        'Estructuras de Datos II',
        'Emprendimiento y Plan de Negocios',
        'Desarrollo Humano II',
        'Inglés A2.1',
        'Metodologia de la Investigación Pura y Aplicada',
      ],
      'Semestre 5': [
        'Probabilidad y Estadística',
        'Programación Móvil y Sist. Embebidos',
        'Bases de Datos I',
        'Comunicación Electrónica',
        'Electiva I',
        'Emprendimiento y Plan de Negocios',
        'Seminario de Desarrollo Humano II',
        'Inglés A2.2',
      ],
      'Semestre 6': [
        'Investigación de Operaciones',
        'Big Data',
        'Bases de Datos II',
        'Redes de Datos',
        'Electiva II',
        'Formulación y Evaluación de Proyectos',
        'Seminario de Desarrollo Humano III',
        'Inglés B1.1',
        'Seminario de Grado I',
      ],
      'Semestre 7': [
        'Simulación Digital',
        'Inteligencia Computacional I',
        'Programación Web Front End',
        'Ingeniería de Software I',
        'Telemática',
        'Hacking I',
        'Inglés B1.2',
        'Seminario de Grado II',
      ],
      'Semestre 8': [
        'Inteligencia Computacional II',
        'Programación Web Back End',
        'Sistemas Distribuidos',
        'Sistemas de Telemetría',
        'Gestión de Seguridad de la Información',
        'Gestión de Proyectos Tecnológicos',
        'Desarrollo de Trabajo de Grado I',
      ],
      'Semestre 9': [
        'Electiva III',
        'Práctica Profesional',
        'Leyes Éticas y Morales',
        'Principios y Normas del Derecho Informático',
        'Desarrollo de Trabajo de Grado II',
      ],
    },
    'Administración de Empresas': {
      'Semestre 1': [
        'Procesos Matemáticos',
        'Ordenamiento Jurídico Constitucional e Institucional',
        'Principios de Organización',
        'Principios Básicos de Contabilidad',
        'Herramientas y Didácticas de la Educación a Distancia',
      ],
      'Semestre 2': [
        'Procesos Estadísticos y Probabilísticos',
        'Planeación Empresarial',
        'Procedimientos Contables en el Manejo de Activos',
        'Agentes Microeconómicos',
        'Métodos y Técnicas de Investigación',
      ],
      'Semestre 3': [
        'Álgebra y Programación Lineal',
        'Bases Jurídicas de la Actividad Empresarial',
        'Organización Empresarial',
        'Procedimientos Contables en el Manejo de Pasivos',
        'Agentes Macroeconómicos',
        'Inglés I',
        'Comprensión de Texto y Lectura Crítica I',
      ],
      'Semestre 4': [
        'Dirección y Control',
        'Procedimientos Contables de Patrimonio y Sociedades',
        'Mercado de Capitales',
        'Investigación de Operaciones',
        'Inglés II',
        'Comprensión de Texto y Lectura Crítica II',
      ],
      'Semestre 5': [
        'Creatividad y Emprendimiento Empresarial',
        'Sistema de Costos',
        'Conocimientos Básicos Tributarios en la Gerencia Empresarial',
        'Administración de la Computación',
        'Gerencia de Mercados',
        'Inglés III',
        'Razonamiento Matemático',
      ],
      'Semestre 6': [
        'Salud y Seguridad en el Trabajo',
        'El Presupuesto como Herramienta Gerencial',
        'Matemáticas Financieras',
        'Investigación de Mercados',
        'Herramientas Tecnológicas Aplicadas a Procesos Administrativos',
        'Inglés IV',
        'Psicología Organizacional',
      ],
      'Semestre 7': [
        'Gerencia de la Calidad',
        'Administración Pública',
        'Electiva I',
        'Análisis Financiero en el Área Administrativa',
        'Administración del Talento Humano',
        'Inglés V',
        'Presaber Específico',
      ],
      'Semestre 8': [
        'Electiva II',
        'Formulación y Evaluación de Proyectos',
        'Administración Finca Raíz',
        'Normas de Auditoría y Conceptos de Control',
        'Comercio Internacional',
        'Proyecto de Investigación',
        'Inglés VI',
      ],
      'Semestre 9': [
        'Procesos Gerenciales en la Administración',
        'Gerencia Financiera',
        'Práctica Empresarial',
        'Desarrollo del Proyecto de Investigación',
        'Leyes Éticas y Morales',
      ],
    },
    'Diseño Visual': {
      'Semestre 1': [
        'Diseño Básico I',
        'Expresión I',
        'Idiomas I',
        'Diseño Digital I',
        'Historia del Diseño I',
        'Técnicas de Estudio',
        'Constitución y Cátedra Para la Paz',
      ],
      'Semestre 2': [
        'Diseño Básico II',
        'Expresión II',
        'Comunicación Oral y Escrita',
        'Idiomas II',
        'Diseño Digital II',
        'Historia del Diseño II',
        'Ética',
      ],
      'Semestre 3': [
        'Diseño Básico III',
        'Expresión III',
        'Idiomas III',
        'Diseño Digital III',
        'Tipografía',
        'Fundamentos Filosóficos del Diseño',
        'Costos y Presupuestos',
      ],
      'Semestre 4': [
        'Proyecto de Diseño I',
        'Comunicación Visual',
        'Idiomas IV',
        'Diseño Digital IV',
        'Fotografía I',
        'Diseño de la Información Visual',
        'Metodología de la Investigación',
      ],
      'Semestre 5': [
        'Proyecto de Diseño II',
        'Taller de Diseño Editorial',
        'Idiomas V',
        'Diseño Digital V',
        'Fotografía II',
        'Electiva I',
        'Procesos Gráficos',
      ],
      'Semestre 6': [
        'Proyecto de Diseño III',
        'Taller de Imagen Corporativa',
        'Seminario de Grado I',
        'Imagen en Movimiento',
        'Idiomas VI',
        'Diseño Digital VI',
        'Electiva II',
      ],
      'Semestre 7': [
        'Proyecto de Diseño IV',
        'Taller de Programa Señalético',
        'Seminario de Grado II',
        'Comunicación Publicitaria',
        'Electiva III',
        'Electiva IV',
        'Práctica Empresarial',
        'Habilidades Gerenciales I',
      ],
      'Semestre 8': [
        'Proyecto de Diseño V',
        'Taller de Empaque y Display',
        'Desarrollo del Proyecto de Grado',
        'Creatividad Publicitaria y Medios',
        'Electiva V',
        'Electiva VI',
        'Formulación y Evaluación de Proyectos',
        'Habilidades Gerenciales II',
      ],
    },
    'Seguridad y Salud en el Trabajo': {
      'Semestre 1': [
        'Matemática Aplicada',
        'Química Aplicada',
        'Fundamentos de Anatomía',
        'Introducción a la Gestión de Riesgos Laborales',
        'Legislación en Riesgos Laborales y Ambientales',
        'Ética Profesional',
        'Constitución y Cátedra de la Paz',
        'Lengua Extranjera Nivel Básico I',
        'Técnicas de Estudio',
      ],
      'Semestre 2': [
        'Estadística Descriptiva',
        'Bioquímica',
        'Fundamentos de Fisiología',
        'Física Aplicada',
        'Peligro y Riesgos Biológicos',
        'Peligro y Riesgos Psicosociales',
        'Peligro y Riesgos Biomecánicos',
        'Técnicas y Comunicación Asertiva',
        'Lengua Extranjera Nivel Básico II',
        'Prevención y Control de Incendio Estructural y Forestal',
      ],
      'Semestre 3': [
        'Bioestadística',
        'Peligro Químico y Riesgos con Materiales Peligrosos',
        'Peligro y Riesgos Físicos',
        'Riesgos y Ergonomía',
        'Peligro y Riesgos Eléctricos',
        'Peligro y Riesgos Locativos',
        'Peligro y Riesgos Mecánicos',
        'Seguridad Física Empresarial',
        'Gestión del Talento Humano',
        'Atención Pre Hospitalaria de Víctimas de Emergencias',
      ],
      'Semestre 4': [
        'Toxicología Ocupacional',
        'Brigadas de Emergencia',
        'Higiene Industrial I',
        'Vigilancia y Epidemiológica Ocupacional',
        'Mantenimiento Físico Preventivo',
        'Administración de Riesgos I',
        'Herramientas Informáticas Aplicadas I',
        'Lengua Extranjera Nivel Intermedio I',
        'Metodología de la Investigación',
      ],
      'Semestre 5': [
        'Saneamiento Básico',
        'Gestión de Planes de Emergencias y Contingencia',
        'Higiene Industrial II',
        'Gestión de la Seguridad Industrial',
        'Cadena de Custodia',
        'Electiva L. Libre',
        'Herramientas Informáticas Aplicadas II',
        'Lengua Extranjera Nivel Intermedio II',
        'Prevención de Riesgos en Espacios Confinados',
      ],
      'Semestre 6': [
        'Riesgos Ambientales',
        'Gestión de la Medicina Preventiva y del Trabajo',
        'Rehabilitación y Reintegro Laboral',
        'Riesgos en la Agroindustria',
        'Prevención en Actividades Críticas',
        'Electiva II: Calidad en el Sector Salud Pública y Auditoría',
        'Seminario de Grado',
        'Sistema Comando de Incidentes',
      ],
      'Semestre 7': [
        'Sistema de Gestión de la Seguridad y Salud en el Trabajo Norma ISO',
        'Gestión del Riesgo de Desastres',
        'Riesgos en la Industria Minera y de Construcción',
        'Riesgos en la Industria Petrolera',
        'Riesgos en la Industria Alimenticia',
        'Administración de Riesgos II',
        'Electiva III: Gestión del Riesgo',
        'Control de Pérdidas',
        'Lengua Extranjera Nivel Específico I',
        'Rescate Vertical',
      ],
      'Semestre 8': [
        'Investigación de Operaciones',
        'Práctica Profesional',
        'Electiva IV: Sistemas de Gestión',
        'Demolición de Estructuras',
        'Lengua Extranjera Nivel Específico II',
        'Trabajo de Grado',
      ],
    },
    'Contaduría Pública': {
      'Semestre 1': [
        'Procedimientos Matemáticos',
        'Ordenamiento Jurídico Constitucional e Institucional',
        'Principios Básicos de Contabilidad Financiera',
        'Administración, Entorno y Alcances',
        'Herramientas Pedagógicas y Didácticas de la Educación a Distancia',
      ],
      'Semestre 2': [
        'Procesos Estadísticos y Probabilísticos',
        'Bases Jurídicas de la Actividad Empresarial',
        'Agentes Macroconómicos',
        'Procedimientos Contables en el Manejo de Activos',
        'Bases Fundamentales de la Planeación',
        'Métodos y Técnicas de Investigación',
      ],
      'Semestre 3': [
        'Normatividad Laboral',
        'Comportamiento Monetario Mundial y Nacional',
        'Procedimientos Contables en el Manejo de Pasivos',
        'Herramientas Financieras',
        'Técnicas de Organización Empresarial',
        'Inglés I',
        'Comprensión de Texto y Lectura Crítica I',
      ],
      'Semestre 4': [
        'Normatividad Sobre Contratación Estatal',
        'Mercados',
        'Procedimientos Contables de Patrimonio y Sociedades',
        'Gestión Financiera',
        'Procesos de Dirección',
        'Inglés II',
        'Comprensión de Texto y Lectura Crítica II',
      ],
      'Semestre 5': [
        'Componentes de la Formulación de Proyectos',
        'Informes Financieros y Matrices y Subsidiarias',
        'Registro de Operaciones Comerciales del Ciclo Contable',
        'Análisis Financiero en el Área Contable',
        'Creatividad Empresarial y Plan de Negocios',
        'Inglés III',
        'Razonamiento Matemático',
      ],
      'Semestre 6': [
        'Elementos del Costo por Órdenes de Producción',
        'Herramientas Tecnológicas Aplicadas a los Sistemas Contables',
        'Normatividad Tributaria Sobre IVA y Retención en la Fuente',
        'El Presupuesto como Herramienta Gerencial',
        'Inglés IV',
        'Psicología Empresarial',
      ],
      'Semestre 7': [
        'Electiva I',
        'Elementos del Costo por Procesos y Estándar',
        'Paquetes Contables',
        'Normatividad Tributaria Sobre Impuesto de Renta y Complementarios',
        'Normas de Auditoría y Aseguramiento',
        'Técnicas de Control',
        'Inglés V',
        'Proyecto de Investigación',
        'Presaber Específico',
      ],
      'Semestre 8': [
        'Procedimientos Contables del Sector Público',
        'Práctica Profesional',
        'Procedimientos Tributarios',
        'Auditoría a los Estados Financieros',
        'Inglés VI',
      ],
      'Semestre 9': [
        'Comercio y Normatividad Internacional',
        'Procedimientos de Registros en Diversos Tipos de Contabilidad',
        'Desarrollo Sostenible Aplicado al Área Contable',
        'Procesos de Revisoría Fiscal',
        'Electiva II',
        'Desarrollo del Proyecto de Investigación',
        'Leyes Éticas y Morales',
      ],
    },
  };

  String? _carreraSeleccionada;
  String? _semestreSeleccionado;
  String? _materiaSeleccionada;
  bool _esEscrituraManual = false;

  Future<void> _seleccionarArchivo() async {
    try {
      FilePickerResult? resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'jpg', 'png', 'pptx'],
        withData: true,
      );

      if (resultado != null) {
        setState(() => _archivoSeleccionado = resultado.files.first);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _subirAlRepositorio() async {
    String asignaturaFinal = _esEscrituraManual
        ? _asignaturaManualController.text.trim()
        : (_materiaSeleccionada ?? '');

    if (_tituloController.text.isEmpty ||
        _carreraSeleccionada == null ||
        _semestreSeleccionado == null ||
        asignaturaFinal.isEmpty ||
        _archivoSeleccionado == null) {
      _mostrarSnack(
        "Completa todos los campos obligatorios y selecciona un archivo",
        Colors.orange,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      String nombreFinal =
          "${DateTime.now().millisecondsSinceEpoch}_${_archivoSeleccionado!.name}";
      Reference ref = FirebaseStorage.instance.ref().child(
        'materiales/$nombreFinal',
      );
      await ref.putData(_archivoSeleccionado!.bytes!);
      String urlDescarga = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('materiales').add({
        'titulo': _tituloController.text.trim(),
        'asignatura': asignaturaFinal,
        'carrera': _carreraSeleccionada,
        'semestre': _semestreSeleccionado,
        'autor': user?.displayName ?? 'Estudiante AUNAR',
        'userId': user?.uid,
        'archivoUrl': urlDescarga,
        'fecha': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _mostrarSnack("¡Archivo publicado con éxito!", Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _mostrarSnack("Error: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarSnack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1565C0);

    List<String> materiasDisponibles = [];
    if (_carreraSeleccionada != null && _semestreSeleccionado != null) {
      final programaFiltrado = _planDeEstudiosCompleto[_carreraSeleccionada];
      if (programaFiltrado != null &&
          programaFiltrado.containsKey(_semestreSeleccionado)) {
        materiasDisponibles = List.from(
          programaFiltrado[_semestreSeleccionado]!,
        );
      }
      materiasDisponibles.add('Otra materia (Escribir manualmente)');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Nuevo Recurso'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Carrera',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school),
                  ),
                  initialValue: _carreraSeleccionada,
                  items: _carreras
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _carreraSeleccionada = v;
                      _materiaSeleccionada = null;
                      _esEscrituraManual = false;
                    });
                  },
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Semestre',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.timeline),
                  ),
                  initialValue: _semestreSeleccionado,
                  items: _semestres
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _semestreSeleccionado = v;
                      _materiaSeleccionada = null;
                      _esEscrituraManual = false;
                    });
                  },
                ),
                const SizedBox(height: 20),

                if (_semestreSeleccionado != null &&
                    _carreraSeleccionada != null) ...[
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Asignatura / Materia',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book),
                    ),
                    initialValue: _materiaSeleccionada,
                    items: materiasDisponibles
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(m, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _materiaSeleccionada = v;
                        _esEscrituraManual =
                            (v == 'Otra materia (Escribir manualmente)');
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                if (_esEscrituraManual) ...[
                  TextField(
                    controller: _asignaturaManualController,
                    decoration: const InputDecoration(
                      labelText: 'Escribe el nombre de la asignatura',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit_note),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                TextField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título del material (ej: Taller Algoritmos)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 25),

                InkWell(
                  onTap: _seleccionarArchivo,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.upload_file,
                          size: 40,
                          color: primaryBlue,
                        ),
                        Text(
                          _archivoSeleccionado == null
                              ? "Seleccionar Archivo"
                              : _archivoSeleccionado!.name,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _subirAlRepositorio,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(18),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SUBIR RECURSO'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
