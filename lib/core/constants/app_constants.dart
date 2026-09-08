/// Constantes transversales de SeguroMina.
abstract final class AppConstants {
  static const String appName = 'SeguroMina';

  /// Idioma por defecto. La app arranca en español y no depende de la
  /// configuración del dispositivo para el MVP.
  static const String defaultLocale = 'es';

  /// Idiomas con archivo de textos disponible en assets/i18n/.
  static const List<String> supportedLocales = <String>['es'];

  /// Rutas del contenido empaquetado.
  static const String i18nPath = 'assets/i18n';
  static const String scenarioIndexPath = 'assets/content/scenarios/index.json';
  static const String scenarioDir = 'assets/content/scenarios';

  /// Nombre del archivo de base de datos local.
  static const String databaseName = 'seguromina.sqlite';
}

/// Identidad de la fuente normativa que respalda el contenido educativo.
///
/// Vive aquí y no dispersa en el código porque el reglamento se modifica
/// periódicamente y toda referencia mostrada al estudiante debe poder
/// rastrearse a una edición concreta.
abstract final class NormativeSource {
  /// Norma base y sus modificatorias conocidas al momento de esta edición.
  static const String decree = 'D.S. N.° 024-2016-EM';
  static const String amendments =
      'modificado por D.S. N.° 023-2017-EM y D.S. N.° 034-2023-EM';

  /// Edición consolidada usada para redactar el contenido.
  static const String edition = 'Edición 2026 (MINEM)';

  static String get full => '$decree, $amendments. $edition';
}

/// Estado de validación del contenido educativo.
///
/// Mientras sea [pendiente], la app muestra un aviso visible al estudiante.
/// Enseñar criterios de seguridad sin revisión de un especialista es un
/// riesgo formativo real y no se oculta detrás de una pantalla bonita.
enum ContentValidationStatus {
  pendiente,
  revisado,
  validado,
}

abstract final class ContentValidation {
  /// Se cambia a [ContentValidationStatus.validado] cuando un ingeniero de
  /// seguridad minera firme la revisión de los cinco escenarios.
  static const ContentValidationStatus status =
      ContentValidationStatus.pendiente;

  static bool get requiresNotice => status != ContentValidationStatus.validado;
}
