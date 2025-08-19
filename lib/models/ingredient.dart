class Ingredient {
  final String id;
  final String nome;
  final String? descricao;
  final String? urlImagem;
  Ingredient({required this.id, required this.nome, this.descricao, this.urlImagem});

  factory Ingredient.fromJson(Map<String, dynamic> j) => Ingredient(
        id: j['id'],
        nome: j['nome'],
        descricao: j['descricao'],
        urlImagem: j['urlImagem'],
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'nome': nome, 'descricao': descricao, 'urlImagem': urlImagem};
}
