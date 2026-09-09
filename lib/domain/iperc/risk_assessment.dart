import '../training/risk_level.dart';

/// Severidad de la consecuencia.
///
/// Las cinco categorias y su orden son las del Anexo 7 del D.S. 024-2016-EM.
/// El `rank` 1 es la peor: asi lo numera la norma y asi lo veran los
/// estudiantes en cualquier matriz de una operacion peruana. Invertirlo para
/// que "mas alto sea peor" resultaria mas intuitivo y les ensenaria mal.
enum Severity {
  catastrofico(1),
  mortalidad(2),
  permanente(3),
  temporal(4),
  menor(5);

  const Severity(this.rank);

  final int rank;

  String get labelKey => 'iperc.severity.$name';
  String get detailKey => 'iperc.severity.$name.detail';
}

/// Probabilidad o frecuencia de ocurrencia, segun el mismo anexo.
enum Probability {
  comun(1),
  haSucedido(2),
  podriaSuceder(3),
  raroQueSuceda(4),
  casiImposible(5);

  const Probability(this.rank);

  final int rank;

  String get labelKey => 'iperc.probability.$name';
  String get detailKey => 'iperc.probability.$name.detail';
}

/// Matriz basica de evaluacion y valoracion de riesgos.
///
/// El indice NO se obtiene multiplicando probabilidad por severidad: sale de
/// una tabla de doble entrada fijada por la norma. Es una diferencia que
/// importa, porque un producto daria un orden distinto al que aplica un
/// supervisor en campo.
///
/// Anexo 7 del D.S. 024-2016-EM, edicion consolidada declarada en
/// `NormativeSource`.
abstract final class RiskMatrix {
  /// Filas: severidad de 1 (catastrofico) a 5 (menor).
  /// Columnas: probabilidad de 1 (comun) a 5 (casi imposible).
  static const List<List<int>> table = <List<int>>[
    <int>[1, 2, 4, 7, 11],
    <int>[3, 5, 8, 12, 16],
    <int>[6, 9, 13, 17, 20],
    <int>[10, 14, 18, 21, 23],
    <int>[15, 19, 22, 24, 25],
  ];

  /// Indice de riesgo, de 1 (el mas grave) a 25.
  static int indexFor({
    required Severity severity,
    required Probability probability,
  }) {
    return table[severity.rank - 1][probability.rank - 1];
  }

  /// Nivel de riesgo a partir del indice.
  ///
  /// Alto 1-8, Medio 9-16, Bajo 17-25. Los cortes son de la norma.
  static RiskLevel levelFor(int index) {
    if (index <= 8) {
      return RiskLevel.alto;
    }
    if (index <= 16) {
      return RiskLevel.medio;
    }
    return RiskLevel.bajo;
  }

  static RiskLevel evaluate({
    required Severity severity,
    required Probability probability,
  }) {
    return levelFor(indexFor(severity: severity, probability: probability));
  }
}

/// Jerarquia de controles.
///
/// El orden es el que decide si un control es aceptable. El punto que mas
/// cuesta a los estudiantes: el EPP es el ultimo nivel, no el primero. No
/// elimina el peligro, solo intenta reducir la consecuencia cuando el peligro
/// ya alcanzo a la persona.
enum ControlLevel {
  eliminacion(1),
  sustitucion(2),
  ingenieria(3),
  administrativo(4),
  epp(5);

  const ControlLevel(this.rank);

  /// 1 es el mas efectivo.
  final int rank;

  String get labelKey => 'control.$name';
  String get detailKey => 'control.$name.detail';
  String get exampleKey => 'control.$name.example';

  bool isMoreEffectiveThan(ControlLevel other) => rank < other.rank;

  /// Controles que actuan sobre el peligro en si, no sobre la persona.
  bool get actsOnHazard => rank <= ControlLevel.ingenieria.rank;
}

/// Una linea de la matriz IPERC: de la actividad al riesgo residual.
class IpercEntry {
  const IpercEntry({
    required this.activityKey,
    required this.hazardKey,
    required this.riskKey,
    required this.severity,
    required this.probability,
    required this.controls,
    required this.residualSeverity,
    required this.residualProbability,
  });

  final String activityKey;
  final String hazardKey;
  final String riskKey;

  final Severity severity;
  final Probability probability;

  /// Controles aplicados, en cualquier orden.
  final List<ControlLevel> controls;

  /// Evaluacion despues de aplicar los controles.
  final Severity residualSeverity;
  final Probability residualProbability;

  int get initialIndex {
    return RiskMatrix.indexFor(severity: severity, probability: probability);
  }

  RiskLevel get initialLevel => RiskMatrix.levelFor(initialIndex);

  int get residualIndex {
    return RiskMatrix.indexFor(
      severity: residualSeverity,
      probability: residualProbability,
    );
  }

  RiskLevel get residualLevel => RiskMatrix.levelFor(residualIndex);

  /// El control mas efectivo aplicado, o nulo si no se aplico ninguno.
  ControlLevel? get strongestControl {
    if (controls.isEmpty) {
      return null;
    }
    var best = controls.first;
    for (final control in controls) {
      if (control.isMoreEffectiveThan(best)) {
        best = control;
      }
    }
    return best;
  }

  /// Un IPERC que solo llega al EPP deja el peligro intacto.
  ///
  /// No lo convierte en invalido —a veces el EPP es lo unico posible— pero si
  /// en una respuesta que hay que justificar, y la app debe senalarlo.
  bool get reliesOnlyOnPpe {
    return controls.isNotEmpty &&
        controls.every((ControlLevel c) => c == ControlLevel.epp);
  }
}
