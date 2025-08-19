class AppUser {
  final String id;
  final String nome;
  final String sobrenome;
  final String email;
  final bool isAtivo;

  AppUser({required this.id, required this.nome, required this.sobrenome, required this.email, required this.isAtivo});

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'],
        nome: j['nome'],
        sobrenome: j['sobrenome'],
        email: j['email'],
        isAtivo: j['isAtivo'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'sobrenome': sobrenome,
        'email': email,
        'isAtivo': isAtivo,
      };
}
