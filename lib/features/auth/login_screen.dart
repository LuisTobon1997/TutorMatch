import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../tutoring/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        UserCredential userCred = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        if (userCred.user != null && !userCred.user!.emailVerified) {
          await userCred.user!.sendEmailVerification();
          await FirebaseAuth.instance.signOut();

          if (mounted) {
            _mostrarMensaje(
              'Correo no verificado. Te enviamos un nuevo enlace a ${_emailController.text}. ¡Revisa tu SPAM!',
              Colors.orange,
            );
          }
        } else {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String mensaje = 'Correo o contraseña incorrectos';
        if (e.code == 'user-not-found') mensaje = 'El usuario no existe.';
        _mostrarMensaje(mensaje, Colors.red);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: color,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 80, color: Colors.indigo),
                const SizedBox(height: 10),
                const Text(
                  'TutorMatch',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: 400,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,

                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Correo Institucional',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (v) =>
                            v!.contains('@') ? null : 'Correo inválido',
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,

                        textInputAction: TextInputAction.done,

                        onFieldSubmitted: (_) => _iniciarSesion(),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (v) =>
                            v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: 400,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Entrar', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  ),
                  child: const Text(
                    '¿No tienes cuenta? Regístrate aquí',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
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
