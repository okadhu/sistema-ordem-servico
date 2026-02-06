class UserModel {
  final int id;
  final String nome;
  final String email;
  final String cargo;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.cargo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? json['name'] ?? "Sem nome",
      email: json['email'] ?? "Sem email",
      cargo: json['cargo'] ?? json['role'] ?? json['funcao'] ?? "Desconhecido",
    );
  }
}
