import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codigoDocenteController = TextEditingController();

  String? _carreraSeleccionada;
  String? _semestreSeleccionado;
  bool _isLoading = false;
  bool _obscureText = true;
  bool _isDocente = false;

  final String _codigoSecretoAunar = "AUNAR-PROFE-2026";

  final List<String> _carreras = [
    'Ingeniería Informática',
    'Administración de Empresas',
    'Contaduría Pública',
    'Diseño Visual',
    'Seguridad y Salud en el Trabajo',
  ];
  final List<String> _semestres = List.generate(10, (i) => "Semestre ${i + 1}");

  Future<void> _registrarUsuario() async {
    final nombre = _nombreController.text.trim();
    final cedula = _cedulaController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final codigo = _codigoDocenteController.text.trim();

    if (nombre.isEmpty || cedula.isEmpty || email.isEmpty || password.isEmpty) {
      _mostrarSnack('Por favor, completa los campos de texto', Colors.orange);
      return;
    }

    if (!_isDocente &&
        (_carreraSeleccionada == null || _semestreSeleccionado == null)) {
      _mostrarSnack(
        'Por favor, selecciona tu programa y semestre',
        Colors.orange,
      );
      return;
    }

    if (_isDocente && codigo != _codigoSecretoAunar) {
      _mostrarSnack(
        'Código institucional de docente incorrecto.',
        Colors.redAccent,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('nombre', isEqualTo: nombre)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _mostrarSnack(
          'Este nombre ya está registrado. Por favor, usa tus dos apellidos o un distintivo.',
          Colors.red,
        );
        setState(() => _isLoading = false);
        return;
      }

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'nombre': nombre,
            'cedula': cedula,
            'carrera': _isDocente ? null : _carreraSeleccionada,
            'semestre': _isDocente ? null : _semestreSeleccionado,
            'email': email,
            'rol': _isDocente ? 'docente' : 'estudiante',
            'fotoUrl': null,
            'fechaRegistro': FieldValue.serverTimestamp(),
          });

      await userCredential.user!.updateDisplayName(nombre);

      if (mounted) {
        _mostrarSnack('¡Registro exitoso!', Colors.green);
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al registrar';
      if (e.code == 'weak-password') {
        mensaje = 'La contraseña es muy débil.';
      } else if (e.code == 'email-already-in-use') {
        mensaje = 'Este correo ya está registrado.';
      }
      _mostrarSnack(mensaje, Colors.red);
    } catch (e) {
      _mostrarSnack('Error: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Registro AUNAR Digital'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Crea tu Perfil",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Todos los campos son obligatorios",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre Completo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _cedulaController,
                    decoration: const InputDecoration(
                      labelText: 'Cédula de Ciudadanía',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (!_isDocente) ...[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Programa Académico',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      items: _carreras
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _carreraSeleccionada = v),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Semestre Actual',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timeline),
                      ),
                      items: _semestres
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _semestreSeleccionado = v),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo Institucional / Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _obscureText = !_obscureText),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isDocente
                          ? primaryBlue.withValues(alpha: 0.05)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isDocente ? primaryBlue : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text(
                            "Soy docente de la AUNAR",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            "Requiere código de verificación",
                            style: TextStyle(fontSize: 12),
                          ),
                          activeThumbColor: primaryBlue,
                          value: _isDocente,
                          onChanged: (bool value) {
                            setState(() {
                              _isDocente = value;
                              if (!value) _codigoDocenteController.clear();
                            });
                          },
                        ),
                        if (_isDocente) ...[
                          const Divider(),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _codigoDocenteController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Código Institucional',
                              prefixIcon: const Icon(
                                Icons.verified_user_rounded,
                                color: Colors.redAccent,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _registrarUsuario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCA28),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'REGISTRARSE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
