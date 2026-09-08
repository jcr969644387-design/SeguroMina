/// Fallos que la capa de datos puede devolver a la de presentación.
///
/// La app no lanza excepciones a través de las capas: los repositorios
/// devuelven [Result] y la UI decide qué mostrar. Esto obliga a que cada
/// pantalla trate explícitamente su estado de error, que es un requisito de
/// calidad del proyecto.
sealed class Failure {
  const Failure(this.message);

  /// Mensaje ya resuelto en el idioma del usuario, listo para mostrarse.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// El contenido empaquetado no se pudo leer o no pasó la validación de
/// esquema. Es un fallo de build, no del usuario: significa que un escenario
/// se publicó mal formado.
final class ContentFailure extends Failure {
  const ContentFailure(super.message, {this.scenarioId});

  final String? scenarioId;
}

/// Error de lectura o escritura en la base de datos local.
final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// El identificador pedido no existe en el catálogo.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Resultado de una operación que puede fallar.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(Failure failure) = Err<T>;

  /// Reduce el resultado a un único valor, obligando a tratar ambos casos.
  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr) {
    return switch (this) {
      Ok<T>(:final T value) => onOk(value),
      Err<T>(:final Failure failure) => onErr(failure),
    };
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
