class OrderModel {
  final int id;
  final int sectorId;
  final int machineId;
  final String prioridade;
  final String? description;
  final String status;
  final String? causaRaiz;
  final double? custo;
  final String operadorNome; // <-- ADICIONADO

  OrderModel({
    required this.id,
    required this.sectorId,
    required this.machineId,
    required this.prioridade,
    this.description,
    required this.status,
    this.causaRaiz,
    this.custo,
    required this.operadorNome,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      sectorId: int.tryParse(json['sector_id'].toString()) ?? 0,
      machineId: int.tryParse(json['machine_id'].toString()) ?? 0,
      prioridade: json['prioridade'] ?? json['priority'] ?? '',
      description: json['descricao'] ?? json['description'],
      status: json['status'] ?? '',
      causaRaiz: json['causa_raiz'],
      custo: json['custo'] != null
          ? double.tryParse(json['custo'].toString())
          : null,
      operadorNome: json['operador_nome'] ?? "Desconhecido",
    );
  }
}
