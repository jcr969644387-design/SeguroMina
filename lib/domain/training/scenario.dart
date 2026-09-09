import 'hazard.dart';
import 'risk_level.dart';

/// Un elemento dibujado en el corte de la labor.
///
/// La escena no se dibuja a mano escenario por escenario: se compone de
/// simbolos tecnicos colocados por coordenadas relativas. Anadir un escenario
/// es escribir contenido, no pintar codigo nuevo.
class SceneElement {
  const SceneElement({
    required this.type,
    required this.x,
    required this.y,
    this.width = 0.12,
    this.height = 0.12,
    this.flip = false,
  });

  /// Simbolo a dibujar. Los conoce el pintor de la escena.
  final String type;

  /// Centro del elemento, en coordenadas relativas (0..1).
  final double x;
  final double y;

  final double width;
  final double height;

  /// Refleja el simbolo horizontalmente.
  final bool flip;
}

/// Perfil de la excavacion.
enum SceneProfile {
  /// Galeria con techo en arco.
  arch,

  /// Labor de seccion rectangular, tipica de camaras y pilares.
  rect,

  /// Rampa con pendiente.
  ramp,
}

class ScenarioScene {
  const ScenarioScene({required this.profile, required this.elements});

  final SceneProfile profile;
  final List<SceneElement> elements;
}

/// Un escenario de entrenamiento completo.
class TrainingScenario {
  const TrainingScenario({
    required this.id,
    required this.code,
    required this.title,
    required this.briefing,
    required this.situation,
    required this.estimatedMinutes,
    required this.scene,
    required this.hazards,
  });

  final String id;

  /// Codigo visible en la ficha ("01", "02"...).
  final String code;

  final String title;

  /// Una linea. Es lo que se ve en el catalogo.
  final String briefing;

  /// Situacion inicial: condiciones de la labor en el momento de la
  /// inspeccion. Sin ellas no se puede evaluar la probabilidad de nada.
  final String situation;

  final int estimatedMinutes;
  final ScenarioScene scene;
  final List<Hazard> hazards;

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
