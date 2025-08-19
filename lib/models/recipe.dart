enum Dificuldade { iniciante, intermediario, avancado }

class Recipe {
  final String id;
  final String idUsuario; // autor/criador
  final String idCategoria;
  final String titulo;
  final String instrucoes;
  final int minutosPreparo;
  final int porcoes;
  final Dificuldade dificuldade;
  final String? urlImagem;
  final DateTime criadoEm;

  Recipe({
    required this.id,
    required this.idUsuario,
    required this.idCategoria,
    required this.titulo,
    required this.instrucoes,
    required this.minutosPreparo,
    required this.porcoes,
    required this.dificuldade,
    this.urlImagem,
    required this.criadoEm,
  });

  factory Recipe.fromJson(Map<String, dynamic> j) => Recipe(
        id: j['id'],
        idUsuario: j['idUsuario'],
        idCategoria: j['idCategoria'],
        titulo: j['titulo'],
        instrucoes: j['instrucoes'],
        minutosPreparo: (j['minutosPreparo'] as num).toInt(),
        porcoes: (j['porcoes'] as num).toInt(),
        dificuldade: _difFromString(j['dificuldade'] as String? ?? 'iniciante'),
        urlImagem: j['urlImagem'],
        criadoEm: DateTime.parse(j['criadoEm']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'idUsuario': idUsuario,
        'idCategoria': idCategoria,
        'titulo': titulo,
        'instrucoes': instrucoes,
        'minutosPreparo': minutosPreparo,
        'porcoes': porcoes,
        'dificuldade': dificuldade.name,
        'urlImagem': urlImagem,
        'criadoEm': criadoEm.toIso8601String(),
      };

  static Dificuldade _difFromString(String s) {
    switch (s) {
      case 'intermediario':
        return Dificuldade.intermediario;
      case 'avancado':
        return Dificuldade.avancado;
      default:
        return Dificuldade.iniciante;
    }
  }
}
