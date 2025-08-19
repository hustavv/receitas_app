class Category {
  final String id;
  final String nome;
  final String? descricao;
  Category({required this.id, required this.nome, this.descricao});

  factory Category.fromJson(Map<String, dynamic> j) =>
      Category(id: j['id'], nome: j['nome'], descricao: j['descricao']);

  Map<String, dynamic> toJson() => {'id': id, 'nome': nome, 'descricao': descricao};
}
