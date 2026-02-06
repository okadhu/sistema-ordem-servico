import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final TextEditingController setorCtrl = TextEditingController();
  final TextEditingController maquinaCtrl = TextEditingController();
  final TextEditingController descricaoCtrl = TextEditingController();

  String prioridade = "baixa";
  bool loading = false;

  Future<void> _createOrder() async {
    final auth = context.read<AuthProvider>();

    if (auth.token == null || auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Você precisa estar logado.")),
      );
      return;
    }

    if (setorCtrl.text.isEmpty ||
        maquinaCtrl.text.isEmpty ||
        descricaoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos.")),
      );
      return;
    }

    final body = {
      "reporter_id": auth.user!.id,
      "sector_id": setorCtrl.text.trim(),
      "machine_id": maquinaCtrl.text.trim(),
      "priority": prioridade,
      "description": descricaoCtrl.text.trim(),
    };

    setState(() => loading = true);

    try {
      await ApiService.post(
        "/orders/create",
        body,
        token: auth.token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ordem criada com sucesso!")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao criar OS: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

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
      appBar: AppBar(
        title: const Text("Criar OS"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: green.withOpacity(0.25),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: setorCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: neonField("Setor"),
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: maquinaCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: neonField("Máquina"),
                      ),
                      const SizedBox(height: 14),

                      DropdownButtonFormField<String>(
                        initialValue: prioridade,
                        dropdownColor: Colors.black,
                        style: const TextStyle(color: Colors.white),
                        decoration: neonField("Prioridade"),
                        items: const [
                          DropdownMenuItem(
                            value: "baixa",
                            child: Text("Baixa", style: TextStyle(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: "alta",
                            child: Text("Alta", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                        onChanged: (v) => setState(() => prioridade = v!),
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: descricaoCtrl,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: neonField("Descrição"),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _createOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Criar OS",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
