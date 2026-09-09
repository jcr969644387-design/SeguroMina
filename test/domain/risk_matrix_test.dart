import 'package:flutter_test/flutter_test.dart';
import 'package:seguromina/domain/iperc/risk_assessment.dart';
import 'package:seguromina/domain/training/risk_level.dart';

/// Matriz basica de evaluacion de riesgos, Anexo 7 del D.S. 024-2016-EM.
///
/// Este test es el que sostiene que la app ensena la matriz que rige en Peru
/// y no una aproximacion. Si alguien la sustituyera por probabilidad por
/// severidad, aqui se vería.
void main() {
  group('Tabla de la norma', () {
    test('el indice sale de la tabla, no de multiplicar', () {
      // Mortalidad (2) con Ha sucedido (2) da 5 en la tabla. El producto de
      // los rangos daria 4, y el nivel resultante seria otro.
      expect(
        RiskMatrix.indexFor(
          severity: Severity.mortalidad,
          probability: Probability.haSucedido,
        ),
        5,
      );
    });

    test('las esquinas coinciden con el anexo', () {
      expect(
        RiskMatrix.indexFor(
          severity: Severity.catastrofico,
          probability: Probability.comun,
        ),
        1,
      );
      expect(
        RiskMatrix.indexFor(
          severity: Severity.catastrofico,
          probability: Probability.casiImposible,
        ),
        11,
      );
      expect(
        RiskMatrix.indexFor(
          severity: Severity.menor,
          probability: Probability.comun,
        ),
        15,
      );
      expect(
        RiskMatrix.indexFor(
          severity: Severity.menor,
          probability: Probability.casiImposible,
        ),
        25,
      );
    });

    test('los 25 indices aparecen exactamente una vez', () {
      final seen = <int>{};
      for (final severity in Severity.values) {
        for (final probability in Probability.values) {
          seen.add(
            RiskMatrix.indexFor(
              severity: severity,
              probability: probability,
            ),
          );
        }
      }
      expect(seen.length, 25);
      expect(seen.reduce((a, b) => a < b ? a : b), 1);
      expect(seen.reduce((a, b) => a > b ? a : b), 25);
    });
  });

  group('Niveles de riesgo', () {
    test('los cortes son 8 y 16', () {
      expect(RiskMatrix.levelFor(1), RiskLevel.alto);
      expect(RiskMatrix.levelFor(8), RiskLevel.alto);
      expect(RiskMatrix.levelFor(9), RiskLevel.medio);
      expect(RiskMatrix.levelFor(16), RiskLevel.medio);
      expect(RiskMatrix.levelFor(17), RiskLevel.bajo);
      expect(RiskMatrix.levelFor(25), RiskLevel.bajo);
    });

    test('una mortalidad que podria suceder sigue siendo riesgo alto', () {
      // Indice 8: el borde superior del nivel Alto. Es el caso que mas se
      // equivoca al leer la matriz a ojo.
      final level = RiskMatrix.evaluate(
        severity: Severity.mortalidad,
        probability: Probability.podriaSuceder,
      );
      expect(level, RiskLevel.alto);
    });
  });

  group('Jerarquia de controles', () {
    test('el orden de eficacia va de eliminacion a EPP', () {
      expect(
        ControlLevel.eliminacion.isMoreEffectiveThan(ControlLevel.epp),
        isTrue,
      );
      expect(
        ControlLevel.epp.isMoreEffectiveThan(ControlLevel.administrativo),
        isFalse,
      );
    });

    test('solo los tres primeros niveles actuan sobre el peligro', () {
      expect(ControlLevel.eliminacion.actsOnHazard, isTrue);
      expect(ControlLevel.ingenieria.actsOnHazard, isTrue);
      expect(ControlLevel.administrativo.actsOnHazard, isFalse);
      expect(ControlLevel.epp.actsOnHazard, isFalse);
    });
  });

  group('Linea de IPERC', () {
    const entry = IpercEntry(
      activityKey: 'a',
      hazardKey: 'h',
      riskKey: 'r',
      severity: Severity.mortalidad,
      probability: Probability.haSucedido,
      controls: <ControlLevel>[
        ControlLevel.ingenieria,
        ControlLevel.administrativo,
      ],
      residualSeverity: Severity.mortalidad,
      residualProbability: Probability.raroQueSuceda,
    );

    test('el control baja la probabilidad y no la severidad', () {
      expect(entry.initialIndex, 5);
      expect(entry.initialLevel, RiskLevel.alto);
      expect(entry.residualIndex, 12);
      expect(entry.residualLevel, RiskLevel.medio);
    });

    test('se identifica el control mas efectivo aplicado', () {
      expect(entry.strongestControl, ControlLevel.ingenieria);
      expect(entry.reliesOnlyOnPpe, isFalse);
    });

    test('un IPERC que solo llega al EPP queda senalado', () {
      const onlyPpe = IpercEntry(
        activityKey: 'a',
        hazardKey: 'h',
        riskKey: 'r',
        severity: Severity.permanente,
        probability: Probability.podriaSuceder,
        controls: <ControlLevel>[ControlLevel.epp],
        residualSeverity: Severity.permanente,
        residualProbability: Probability.raroQueSuceda,
      );

      expect(onlyPpe.reliesOnlyOnPpe, isTrue);
    });
  });
}
