import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/orders_provider.dart';
import '../../../core/providers/auth_provider.dart';

class GestorDashboardPage extends StatefulWidget {
  const GestorDashboardPage({super.key});

  @override
  State<GestorDashboardPage> createState() => _GestorDashboardPageState();
}

class _GestorDashboardPageState extends State<GestorDashboardPage> {
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final auth = context.read<AuthProvider>();
    await context.read<OrdersProvider>().fetchOrders(auth.token!);
  }

  // Normaliza status para cor/badge
  Color statusColor(String? status) {
    final s = (status ?? '').toString().toLowerCase();
    if (s.contains('aberto')) return Colors.greenAccent;
    if (s.contains('em_execucao') || s.contains('em andamento') || s.contains('em_andamento')) {
      return Colors.orangeAccent;
    }
    if (s.contains('concluido') || s.contains('fechado')) return Colors.grey;
    return Colors.white70;
  }

  // rank para ordenar status: aberto(1) < em andamento(2) < fechado(3)
  int statusRank(String? status) {
    final s = (status ?? '').toString().toLowerCase();
    if (s.contains('aberto')) return 1;
    if (s.contains('em_execucao') || s.contains('em andamento') || s.contains('em_andamento')) return 2;
    if (s.contains('concluido') || s.contains('fechado')) return 3;
    return 4;
  }

  // rank para prioridade: alta(1) < media(2) < baixa(3)
  int prioridadeRank(String? p) {
    final s = (p ?? '').toString().toLowerCase();
    if (s == 'alta' || s == 'high') return 1;
    if (s == 'media' || s == 'média' || s == 'media') return 2;
    if (s == 'baixa' || s == 'low') return 3;
    return 4;
  }

  // Tenta extrair machine id de várias chaves possíveis (retorna string)
 String extractMachineId(dynamic os) {
  try {
    final candidates = [
     () => os.machine_id,
() => os.machineId,
() => os.maquina,
() => os['maquina'],
() => os['machine_id'],
() => os['machineId'],

    ];

    for (var c in candidates) {
      try {
        final v = c();
        if (v != null) {
          final s = v.toString().trim();
          if (s.isNotEmpty && s != "0") return s;
        }
      } catch (_) {}
    }
  } catch (_) {}

  return "Não informado";
}

  // Tenta extrair operador/repórter nome; se não tiver nome, retorna "Usuário <id>" ou "Não informado"
 String extractReporterName(dynamic os) {
  try {
    final nameCandidates = [
      () => os.operador_nome,
      () => os.operadorName,
      () => os['operador_nome'],
      () => os['operadorName'],
    ];

    for (var c in nameCandidates) {
      try {
        final v = c();
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      } catch (_) {}
    }

    final idCandidates = [
      () => os.operador_id,
      () => os.reporter_id,
      () => os['operador_id'],
      () => os['reporter_id'],
      () => os.operador_nome,
() => os['operador_nome'],
() => os['operadorName'],
() => os['operador'],
() => os['nome_operador']

    ];

    for (var c in idCandidates) {
      try {
        final v = c();
        if (v != null) return "Usuário ${v.toString()}";
      } catch (_) {}
    }
  } catch (_) {}

  return "Não informado";
}


  String custoLabel(dynamic custo) {
    if (custo == null) return 'R\$ 0,00';
    try {
      if (custo is num) return 'R\$ ${custo.toStringAsFixed(2)}';
      final parsed = double.tryParse(custo.toString());
      if (parsed != null) return 'R\$ ${parsed.toStringAsFixed(2)}';
      return 'R\$ ${custo.toString()}';
    } catch (_) {
      return 'R\$ ${custo.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // provider retorna lista (provavelmente de OrderModel ou map)
    final ordersRaw = context.watch<OrdersProvider>().orders;

    // converte para lista mutável de dynamic
    final List<dynamic> orders = List<dynamic>.from(ordersRaw);

    // Agrupamento por máquina — usamos extractMachineId
    final Map<String, int> osPorMaquina = {};
    for (var os in orders) {
      final machineId = extractMachineId(os);
      osPorMaquina[machineId] = (osPorMaquina[machineId] ?? 0) + 1;
    }

    // ordenar máquinas por quantidade desc
    final sortedOsPorMaquina = osPorMaquina.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // calculos de resumo (usamos extração segura)
    final totalOs = orders.length;
    final totalFechadas = orders.where((o) {
      final s = ((o?.status ?? '')).toString().toLowerCase();
      return s.contains('concluido') || s.contains('fechado');
    }).length;
    final totalAndamento = orders.where((o) {
      final s = ((o?.status ?? '')).toString().toLowerCase();
      return s.contains('em_execucao') || s.contains('em andamento') || s.contains('em_andamento');
    }).length;
    final totalAbertas = orders.where((o) {
      final s = ((o?.status ?? '')).toString().toLowerCase();
      return s.contains('aberto');
    }).length;

    double totalCustos = 0;
    for (var os in orders) {
      final c = os?.custo;
      if (c == null) continue;
      if (c is num) totalCustos += c.toDouble();
      else {
        final parsed = double.tryParse(c.toString());
        if (parsed != null) totalCustos += parsed;
      }
    }

    // Ordena a lista completa: primeiro por statusRank, depois prioridadeRank, depois data_abertura desc (se existir)
    orders.sort((a, b) {
      final aStatus = (a?.status ?? '').toString();
      final bStatus = (b?.status ?? '').toString();
      final sa = statusRank(aStatus);
      final sb = statusRank(bStatus);
      if (sa != sb) return sa.compareTo(sb);

      final aPri = (a?.prioridade ?? '').toString();
      final bPri = (b?.prioridade ?? '').toString();
      final pa = prioridadeRank(aPri);
      final pb = prioridadeRank(bPri);
      if (pa != pb) return pa.compareTo(pb);

      // por último, ordenar por data_abertura desc se existir
      try {
        final aDateRaw = a?.data_abertura ?? a?.dataAbertura ?? a?['data_abertura'];
        final bDateRaw = b?.data_abertura ?? b?.dataAbertura ?? b?['data_abertura'];
        if (aDateRaw != null && bDateRaw != null) {
          final aDate = DateTime.parse(aDateRaw.toString());
          final bDate = DateTime.parse(bDateRaw.toString());
          return bDate.compareTo(aDate);
        }
      } catch (_) {}
      return 0;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel do Gestor"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF0A0A0A),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // CARDS RESUMO
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                buildInfoCard("Total de OS", totalOs.toString(), Colors.blue),
                buildInfoCard("OS Abertas", totalAbertas.toString(), Colors.green),
                buildInfoCard("OS em Andamento", totalAndamento.toString(), Colors.orange),
                buildInfoCard("OS Fechadas", totalFechadas.toString(), Colors.grey),
                buildInfoCard("Total em Custos", "R\$ ${totalCustos.toStringAsFixed(2)}", Colors.purple),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "OS por Máquina",
              style: TextStyle(color: Colors.greenAccent, fontSize: 20),
            ),
            const SizedBox(height: 10),

            // Lista máquinas (ordenada)
            ...sortedOsPorMaquina.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        entry.key,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Text(
                      "${entry.value} OS",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 25),

            const Text(
              "Lista Completa de OS",
              style: TextStyle(color: Colors.greenAccent, fontSize: 20),
            ),

            const SizedBox(height: 10),

            // Lista completa (ordenada)
            ...orders.map((os) => buildOsItem(os)).toList(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCard(String title, String value, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget buildOsItem(dynamic os) {
    final statusRaw = ((os?.status ?? '')).toString();
    final machineIdLabel = extractMachineId(os);
    final reporter = extractReporterName(os);
    final prioridade = ((os?.prioridade ?? '')).toString();
    final custo = custoLabel(os?.custo);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: // if closed -> slightly greyed out background
            (statusRaw.toLowerCase().contains('concluido') || statusRaw.toLowerCase().contains('fechado'))
                ? Colors.grey.shade800
                : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header: id + status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("OS #${os?.id ?? '?'}", style: const TextStyle(color: Colors.white, fontSize: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor(statusRaw).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusRaw.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(color: statusColor(statusRaw), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text("Máquina: $machineIdLabel", style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text("Feita por: $reporter", style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),

          Text("Prioridade: ${prioridade.toUpperCase()}",
              style: TextStyle(
                color: prioridade.toLowerCase() == 'alta'
                    ? Colors.redAccent
                    : prioridade.toLowerCase() == 'media'
                        ? Colors.amberAccent
                        : Colors.greenAccent,
                fontWeight: FontWeight.bold,
              )),

          const SizedBox(height: 8),

          Text("Custo: $custo", style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
