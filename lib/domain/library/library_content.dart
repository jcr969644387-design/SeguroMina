/// Contenido de la biblioteca de seguridad.
///
/// A diferencia de los textos de interfaz, que viven en `assets/i18n/`, esto
/// es material didactico: crece, se corrige y se somete a revision tecnica
/// sin tocar codigo. Por eso se carga desde `assets/content/` y los modelos
/// llevan el texto, no claves.
class LibrarySection {
  const LibrarySection({required this.heading, required this.body});

  final String heading;
  final String body;
}

/// Pregunta de comprobacion al final de una ficha.
///
/// No puntua ni bloquea: sirve para que el estudiante sepa si entendio antes
/// de pasar a practicar. La evaluacion con nota es otra cosa y vive aparte.
class CheckQuestion {
  const CheckQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;

  /// Por que la respuesta correcta lo es. Se muestra siempre, se acierte o
  /// no: la explicacion es el contenido, no el premio.
  final String explanation;

  bool isCorrect(int index) => index == correctIndex;
}

class LibraryTopic {
  const LibraryTopic({
    required this.id,
    required this.title,
    required this.summary,
    required this.sections,
    required this.miningExample,
    this.diagram,
    this.check,
  });

  final String id;
  final String title;

  /// Una linea. Es lo que se ve en el listado.
  final String summary;

  final List<LibrarySection> sections;

  /// Aplicacion concreta en una operacion minera. Obligatorio: un concepto de
  /// seguridad sin ejemplo de campo no se retiene.
  final String miningExample;

  /// Identificador del diagrama tecnico que acompana a la ficha.
  final String? diagram;

  final CheckQuestion? check;
}

class LibraryCategory {
  const LibraryCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.topics,
  });

  final String id;
  final String title;
  final String description;
  final List<LibraryTopic> topics;
}

class LibraryContent {
  const LibraryContent({required this.categories});

  final List<LibraryCategory> categories;

  int get topicCount {
    var total = 0;
    for (final category in categories) {
      total += category.topics.length;
    }
    return total;
  }

  List<LibraryTopic> get allTopics {
    return <LibraryTopic>[
      for (final category in categories) ...category.topics,
    ];
  }

  LibraryTopic? topicById(String id) {
    for (final topic in allTopics) {
      if (topic.id == id) {
        return topic;
      }
    }
    return null;
  }

  LibraryCategory? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }
}
