import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color kPrimaryBlue = Color(0xFF1565C0);

class ProgramarTutoriaScreen extends StatefulWidget {
  const ProgramarTutoriaScreen({super.key});

  @override
  State<ProgramarTutoriaScreen> createState() => _ProgramarTutoriaScreenState();
}

class _ProgramarTutoriaScreenState extends State<ProgramarTutoriaScreen> {
  final _tituloController = TextEditingController();
  bool _isLoading = false;

  String? _carreraSeleccionada;
  String? _semestreSeleccionado;
  String? _materiaSeleccionada;
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  final List<String> _carreras = [
    'Ingeniería Informática',
    'Administración de Empresas',
    'Contaduría Pública',
    'Diseño Visual',
    'Seguridad y Salud en el Trabajo',
  ];
  final List<String> _semestres = List.generate(10, (i) => "Semestre ${i + 1}");

  final Map<String, Map<String, List<String>>> _planDeEstudios = {
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
        'Administración de la Producción',
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

  Future<void> _seleccionarFechaHora() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (fecha != null) {
      if (!mounted) return;
      final TimeOfDay? hora = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 18, minute: 0),
      );
      if (hora != null) {
        setState(() {
          _fechaSeleccionada = fecha;
          _horaSeleccionada = hora;
        });
      }
    }
  }

  Future<void> _agendarTutoria() async {
    if (_tituloController.text.isEmpty ||
        _carreraSeleccionada == null ||
        _semestreSeleccionado == null ||
        _materiaSeleccionada == null ||
        _fechaSeleccionada == null ||
        _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      final String horaFormateada = _horaSeleccionada!.format(context);

      final DateTime fechaFinal = DateTime(
        _fechaSeleccionada!.year,
        _fechaSeleccionada!.month,
        _fechaSeleccionada!.day,
        _horaSeleccionada!.hour,
        _horaSeleccionada!.minute,
      );

      await FirebaseFirestore.instance.collection('tutorias_en_vivo').add({
        'titulo': _tituloController.text.trim(),
        'docenteId': user?.uid,
        'docenteNombre': user?.displayName ?? 'Docente AUNAR',
        'carrera': _carreraSeleccionada,
        'semestre': _semestreSeleccionado,
        'materia': _materiaSeleccionada,
        'fechaProgramada': Timestamp.fromDate(fechaFinal),
        'estado': 'programada',
        'urlGrabacion': '',
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      final estudiantesQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('carrera', isEqualTo: _carreraSeleccionada)
          .where('semestre', isEqualTo: _semestreSeleccionado)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var estudiante in estudiantesQuery.docs) {
        if (estudiante.id != user?.uid) {
          final notifRef = FirebaseFirestore.instance
              .collection('users')
              .doc(estudiante.id)
              .collection('notificaciones')
              .doc();
          batch.set(notifRef, {
            'remitenteNombre': 'Sistema AUNAR',
            'puntuacion': 0,
            'materia': _materiaSeleccionada,
            'comentario':
                '¡Nueva tutoría en vivo agendada! ${fechaFinal.day}/${fechaFinal.month} a las $horaFormateada',
            'fecha': FieldValue.serverTimestamp(),
            'leida': false,
          });
        }
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Tutoría agendada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> materiasDisponibles = [];
    if (_carreraSeleccionada != null && _semestreSeleccionado != null) {
      final programa = _planDeEstudios[_carreraSeleccionada];
      if (programa != null && programa.containsKey(_semestreSeleccionado)) {
        materiasDisponibles = List.from(programa[_semestreSeleccionado]!);
      }
      materiasDisponibles.add('Otra materia (General)');
    }

    String fechaTexto = _fechaSeleccionada != null && _horaSeleccionada != null
        ? "${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year} - ${_horaSeleccionada!.format(context)}"
        : "Seleccionar Fecha y Hora";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Programar Tutoría en Vivo'),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(
                      Icons.video_camera_front_rounded,
                      size: 60,
                      color: kPrimaryBlue,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Configura la sesión para tus estudiantes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),

                    TextField(
                      controller: _tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Tema o Título de la Clase',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Carrera Objetivo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      items: _carreras
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() {
                        _carreraSeleccionada = v;
                        _materiaSeleccionada = null;
                      }),
                    ),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Semestre',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timeline),
                      ),
                      items: _semestres
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() {
                        _semestreSeleccionado = v;
                        _materiaSeleccionada = null;
                      }),
                    ),
                    const SizedBox(height: 20),

                    if (materiasDisponibles.isNotEmpty)
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Materia',
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
                        onChanged: (v) =>
                            setState(() => _materiaSeleccionada = v),
                      ),

                    const SizedBox(height: 20),
                    InkWell(
                      onTap: _seleccionarFechaHora,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Agendamiento',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_month_rounded),
                        ),
                        child: Text(
                          fechaTexto,
                          style: TextStyle(
                            fontSize: 16,
                            color: _fechaSeleccionada == null
                                ? Colors.grey
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        onPressed: _isLoading ? null : _agendarTutoria,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'AGENDAR CLASE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
