import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final senhaCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF00FF88);

    InputDecoration neonField(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: green),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: green, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: green, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: Container(
            width: 330,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: green.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 60, color: green),
                const SizedBox(height: 16),
                const Text(
                  "Acesso ao Sistema",
                  style: TextStyle(
                    color: green,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                // Email
                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: neonField("E-mail"),
                ),
                const SizedBox(height: 14),

                // Senha
                TextField(
                  controller: senhaCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: neonField("Senha"),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (loading) return;

                      setState(() => loading = true);

                      final ok = await context
                          .read<AuthProvider>()
                          .login(emailCtrl.text, senhaCtrl.text);

                      setState(() => loading = false);

                      if (ok) {
                        Navigator.pushReplacementNamed(context, "/dashboard");
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Credenciais inválidas")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "Entrar",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Sistema OS • AgroTech",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
