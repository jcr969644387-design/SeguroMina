/// Nivel de riesgo segun la matriz IPERC.
///
/// Dart puro y sin dependencias: el motor de evaluacion debe poder auditarse
/// por un especialista sin abrir Flutter.
enum RiskLevel {
  bajo,
  medio,
  alto;

  /// Peso del peligro en la puntuacion. Un peligro alto no vale lo mismo que
  /// uno bajo: pasar por alto una roca fracturada es peor que pasar por alto
  /// un cable mal tendido.
  int get weight {
    switch (this) {
      case RiskLevel.bajo:
        return 1;
      case RiskLevel.medio:
        return 2;
      case RiskLevel.alto:
        return 3;
    }
  }

  /// Clave de texto del nivel. El dominio no conoce cadenas visibles.
  String get labelKey => 'risk.$name';

  /// Rango de indices de la matriz que corresponde al nivel.
  String get rangeKey => 'risk.$name.range';

  /// Plazo maximo de correccion que fija la norma para el nivel.
  String get deadlineKey => 'risk.$name.deadline';
}
