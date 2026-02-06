import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../../core/providers/auth_provider.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Map<String, dynamic>? order;
  bool loading = true;

  String? statusSelecionado;
  final List<String> statusOptions = ["Aberto", "Em andamento", "Fechado"];

  final TextEditingController causaRaizController = TextEditingController();
  final TextEditingController custoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarDetalhes();
  }

  Future<void> carregarDetalhes() async {
    final auth = context.read<AuthProvider>();
    final url = Uri.parse("http://172.29.192.1:3000/orders/${widget.orderId}");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (auth.token != null) "Authorization": "Bearer ${auth.token}",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;
        setState(() {
          order = data;
          statusSelecionado = data["status"]?.toString();
          causaRaizController.text = (data["causa_raiz"] ?? "").toString();
          custoController.text = (data["custo"] ?? "0").toString();
          loading = false;
        });
      } else {
        erroSnack("Erro ao carregar OS (HTTP ${response.statusCode})");
      }
    } catch (e) {
      erroSnack("Erro ao carregar OS: $e");
    }
  }

  Future<void> atualizarOS() async {
    final auth = context.read<AuthProvider>();

    final url = Uri.parse("http://172.29.192.1:3000/orders/${widget.orderId}");

    final body = {
      "status": statusSelecionado ?? "",
      "causa_raiz": causaRaizController.text.trim(),
      "custo": custoController.text.trim(),
    };

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${auth.token}",
        },
        body: jsonEncode(body),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OS atualizada com sucesso!")),
        );
        carregarDetalhes();
      } else {
        erroSnack("Erro ao atualizar OS (HTTP ${response.statusCode})");
      }
    } catch (e) {
      erroSnack("Erro ao atualizar OS: $e");
    }
  }

  void erroSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color verde = Color(0xFF00FF7F);
    const Color fundo = Color(0xFF0A0A0A);

    if (loading) {
      return const Scaffold(
        backgroundColor: fundo,
        body: Center(
          child: CircularProgressIndicator(color: Colors.greenAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: verde),
        title: Text(
          "Detalhes da OS #${widget.orderId}",
          style: const TextStyle(color: verde),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            buildInfo("Máquina", order?["maquina"]),
            buildInfo("Setor", order?["setor"]),
            buildInfo("Data", order?["data_hora"]),
            const SizedBox(height: 20),

            buildLabel("Status atual"),
            const SizedBox(height: 8),

            // ===================
            //   DROPDOWN STATUS
            // ===================
            DropdownButtonFormField<String>(
              value: statusSelecionado,
              dropdownColor: Colors.black,
              iconEnabledColor: Colors.greenAccent,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.greenAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.greenAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00FF7F), width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              items: statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  statusSelecionado = value;
                });
              },
            ),

            const SizedBox(height: 16),
            buildLabel("Causa raiz"),
            buildInput(causaRaizController, maxLines: 3),

            const SizedBox(height: 16),
            buildLabel("Custo da manutenção"),
            buildInput(custoController, keyboardType: TextInputType.number),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: atualizarOS,
              style: ElevatedButton.styleFrom(
                backgroundColor: verde,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text("Salvar alterações"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfo(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        "$label: ${value ?? 'Não informado'}",
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.greenAccent, fontSize: 16),
    );
  }

  Widget buildInput(
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.greenAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.greenAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00FF7F), width: 2),
        ),
      ),
    );
  }
}
