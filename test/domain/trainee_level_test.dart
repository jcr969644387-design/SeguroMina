import 'package:flutter_test/flutter_test.dart';
import 'package:seguromina/domain/progress/trainee_level.dart';

void main() {
  test('el nivel se deriva de los puntos', () {
    expect(TraineeLevel.forPoints(0), TraineeLevel.principiante);
    expect(TraineeLevel.forPoints(299), TraineeLevel.principiante);
    expect(TraineeLevel.forPoints(300), TraineeLevel.intermedio);
    expect(TraineeLevel.forPoints(899), TraineeLevel.intermedio);
    expect(TraineeLevel.forPoints(900), TraineeLevel.experto);
  });

  test('el avance hacia el siguiente nivel va de 0 a 1', () {
    expect(TraineeLevel.progressForPoints(0), 0);
    expect(TraineeLevel.progressForPoints(150), 0.5);
    expect(TraineeLevel.progressForPoints(300), 0);
  });

  test('en el nivel maximo el avance esta completo', () {
    expect(TraineeLevel.progressForPoints(900), 1);
    expect(TraineeLevel.progressForPoints(5000), 1);
  });
}
