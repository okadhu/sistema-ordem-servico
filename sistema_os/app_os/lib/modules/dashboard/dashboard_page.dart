import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF00FF88);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
      ),

      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Bem-vindo ao Sistema OS",
                style: TextStyle(
                  fontSize: 22,
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // BOTÃO LISTAR OS
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, "/orders");
                },
                icon: const Icon(Icons.list, color: Colors.black),
                label: const Text(
                  "Listar Ordens de Serviço",
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // BOTÃO CRIAR OS
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, "/create_order");
                },
                icon: const Icon(Icons.add_circle, color: Colors.black),
                label: const Text(
                  "Criar Nova OS",
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // BOTÃO PAINEL GESTOR
             ElevatedButton.icon(
  onPressed: () {
    Navigator.pushNamed(context, "/gestor_dashboard");
  },
  icon: const Icon(Icons.monitor, color: Colors.black),
  label: const Text(
    "Dashboard Gestor",
    style: TextStyle(color: Colors.black),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryGreen,
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),

            ],
          ),
        ),
      ),
    );
  }
}
