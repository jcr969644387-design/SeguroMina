import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/library/library_content.dart';
import 'library_parser.dart';

/// Acceso al contenido de la biblioteca.
abstract interface class LibraryRepository {
  Future<LibraryContent> load();
}

/// Lee el contenido empaquetado en la aplicacion.
///
/// La app es offline-first: el material de estudio viaja dentro del APK y no
/// depende de que el estudiante tenga senal dentro de una labor.
class AssetLibraryRepository implements LibraryRepository {
  const AssetLibraryRepository();

  @override
  Future<LibraryContent> load() async {
    final raw = await rootBundle.loadString(AppConstants.libraryPath);
    return parseLibraryContent(raw);
  }
}

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return const AssetLibraryRepository();
});

final libraryContentProvider = FutureProvider<LibraryContent>((ref) {
  return ref.watch(libraryRepositoryProvider).load();
});
