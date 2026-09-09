import 'hazard.dart';
import 'risk_level.dart';

/// Definicion de una mision de entrenamiento.
class Mission {
  const Mission({
    required this.id,
    required this.code,
    required this.titleKey,
    required this.briefingKey,
    required this.hazards,
    required this.estimatedMinutes,
  });

  final String id;

  /// Codigo visible en la ficha de mision ("00", "03"...).
  final String code;

  final String titleKey;
  final String briefingKey;
  final List<Hazard> hazards;
  final int estimatedMinutes;

  /// Riesgo dominante de la escena. Determina el distintivo de la ficha.
  RiskLevel get dominantRisk {
    var worst = RiskLevel.bajo;
    for (final hazard in hazards) {
      if (hazard.severity.weight > worst.weight) {
        worst = hazard.severity;
      }
    }
    return worst;
  }
}

/// Mision 00: la galeria de acceso.
///
/// Es la primera experiencia del estudiante y por eso es corta y deliberada.
/// Los tres peligros cubren las tres familias que estructuran el resto del
/// entrenamiento: condicion del terreno, instalacion provisional y acto
/// inseguro de una persona. No pretende ser exhaustiva.
///
/// El contenido es material academico de demostracion y no reemplaza el
/// procedimiento escrito de trabajo seguro de una operacion real.
abstract final class IntroMission {
  static const Mission definition = Mission(
    id: 'mission-00-galeria',
    code: '00',
    titleKey: 'mission.intro.title',
    briefingKey: 'mission.intro.briefing',
    estimatedMinutes: 1,
    hazards: <Hazard>[
      Hazard(
        id: 'roca-fracturada',
        labelKey: 'hazard.rock.label',
        explanationKey: 'hazard.rock.explanation',
        controlKey: 'hazard.rock.control',
        severity: RiskLevel.alto,
        area: HazardArea(left: 0.58, top: 0.14, width: 0.30, height: 0.24),
      ),
      Hazard(
        id: 'sin-proteccion-ocular',
        labelKey: 'hazard.eyes.label',
        explanationKey: 'hazard.eyes.explanation',
        controlKey: 'hazard.eyes.control',
        severity: RiskLevel.medio,
        area: HazardArea(left: 0.42, top: 0.40, width: 0.24, height: 0.32),
      ),
      Hazard(
        id: 'cable-en-piso',
        labelKey: 'hazard.cable.label',
        explanationKey: 'hazard.cable.explanation',
        controlKey: 'hazard.cable.control',
        severity: RiskLevel.medio,
        area: HazardArea(left: 0.06, top: 0.70, width: 0.36, height: 0.18),
      ),
    ],
  );
}
