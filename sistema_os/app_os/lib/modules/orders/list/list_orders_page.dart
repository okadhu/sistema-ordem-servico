import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/orders_provider.dart';
import '../../../core/providers/auth_provider.dart';

class ListOrdersPage extends StatefulWidget {
const ListOrdersPage({super.key});

@override
State<ListOrdersPage> createState() => _ListOrdersPageState();
}

class _ListOrdersPageState extends State<ListOrdersPage> {
Future<void> load() async {
final auth = context.read<AuthProvider>();
await context.read<OrdersProvider>().fetchOrders(auth.token!);
}

@override
void initState() {
super.initState();
load();
}

/// COR: Prioridade
Color prioridadeColor(String p) {
switch (p) {
case "alta":
return Colors.redAccent;
case "media":
return Colors.amberAccent;
default:
return Colors.greenAccent;
}
}

/// COR: Status
Color statusColor(String s) {
switch (s) {
case "aberto":
return Colors.greenAccent;
case "em_execucao":
case "em_andamento":
return Colors.amberAccent;
case "concluido":
case "fechado":
return Colors.grey;
default:
return Colors.grey;
}
}

/// ORDENAR OS
int orderSorter(os) {
  // Prioridade (quanto maior o peso, mais alta a prioridade)
  final prioridadePeso = {
    "alta": 1,      // primeiro
    "media": 2,
    "baixa": 3,     // último
  };

  // Status (quanto menor o peso, mais acima fica)
  final statusPeso = {
    "aberto": 1,        // topo
    "em_execucao": 2,   // meio
    "em_andamento": 2,  // meio
    "concluido": 3,     // fim
    "fechado": 3,       // fim
  };

  return (statusPeso[os.status] ?? 2) * 10 +
         (prioridadePeso[os.prioridade] ?? 2);
}

@override
Widget build(BuildContext context) {
final ordersProvider = context.watch<OrdersProvider>();
final orders = [...ordersProvider.orders];

/// APLICAA ORDENACAO
orders.sort((a, b) => orderSorter(a).compareTo(orderSorter(b)));

return Scaffold(
  appBar: AppBar(
    title: const Text("Ordens de Serviço"),
    centerTitle: true,
  ),

  floatingActionButton: FloatingActionButton(
    onPressed: () async {
      final created = await Navigator.pushNamed(context, "/create_order");
      if (created == true) load();
    },
    child: const Icon(Icons.add, size: 32),
  ),

  body: orders.isEmpty
      ? const Center(
          child: Text(
            "Nenhuma OS encontrada.",
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        )
      : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final os = orders[index];

            /// DEIXA CARTÃO CINZA APAGADO QUANDO FECHADO/CONCLUIDO
            final bool isClosed =
                os.status == "fechado" || os.status == "concluido";

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              shadowColor: Colors.greenAccent.withOpacity(0.3),
              margin: const EdgeInsets.only(bottom: 16),
              color: isClosed ? Colors.grey.shade800 : Colors.grey.shade900,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "/order_details",
                    arguments: os.id,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Ícone de prioridade
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: prioridadeColor(os.prioridade)
                            .withOpacity(0.2),
                        child: Icon(
                          Icons.build,
                          color: prioridadeColor(os.prioridade),
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// TEXTOS
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Cabeçalho: ID + STATUS
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "OS #${os.id}",
                                  style: TextStyle(
                                    color:
                                        isClosed ? Colors.white60 : Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor(os.status)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    os.status.replaceAll("_", " ").toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor(os.status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            /// Prioridade
                            Text(
                              "Prioridade: ${os.prioridade.toUpperCase()}",
                              style: TextStyle(
                                color: prioridadeColor(os.prioridade),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 8),

                            /// Descrição
                            Text(
                              os.description ?? "Sem descrição",
                              style: TextStyle(
                                color:
                                    isClosed ? Colors.white54 : Colors.white70,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
);


}
}
