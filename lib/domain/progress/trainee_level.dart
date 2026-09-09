/// Nivel del estudiante dentro del centro de entrenamiento.
///
/// Se deriva de los puntos acumulados y no se guarda como dato aparte: un
/// unico origen de verdad evita que el nivel y los puntos se contradigan.
enum TraineeLevel {
  principiante,
  intermedio,
  experto;

  String get labelKey => 'level.$name';

  /// Puntos necesarios para alcanzar el nivel.
  int get threshold {
    switch (this) {
      case TraineeLevel.principiante:
        return 0;
      case TraineeLevel.intermedio:
        return 300;
      case TraineeLevel.experto:
        return 900;
    }
  }

  static TraineeLevel forPoints(int points) {
    if (points >= TraineeLevel.experto.threshold) {
      return TraineeLevel.experto;
    }
    if (points >= TraineeLevel.intermedio.threshold) {
      return TraineeLevel.intermedio;
    }
    return TraineeLevel.principiante;
  }

  /// Avance hacia el siguiente nivel, de 0 a 1. En el nivel maximo es 1.
  static double progressForPoints(int points) {
    final current = forPoints(points);
    if (current == TraineeLevel.experto) {
      return 1;
    }
    final next = current == TraineeLevel.principiante
        ? TraineeLevel.intermedio
        : TraineeLevel.experto;
    final span = next.threshold - current.threshold;
    final done = points - current.threshold;
    return (done / span).clamp(0.0, 1.0);
  }
}
