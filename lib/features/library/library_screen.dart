import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/pressable_card.dart';
import '../../data/library/library_repository.dart';
import '../../domain/library/library_content.dart';
import 'topic_screen.dart';

/// Biblioteca de seguridad.
///
/// Es la mitad "aprender" del ciclo. Va antes que los escenarios de forma
/// deliberada: evaluar a un estudiante sobre un criterio que nadie le explico
/// no mide su formacion, mide lo que ya sabia al llegar.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider).valueOrNull;
    final content = ref.watch(libraryContentProvider);

    if (strings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings('library.title'))),
      body: content.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ContentError(strings: strings, error: error),
        data: (LibraryContent library) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: <Widget>[
            Text(
              strings('library.subtitle'),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final category in library.categories) ...<Widget>[
              _CategoryHeader(category: category, strings: strings),
              const SizedBox(height: AppSpacing.sm),
              for (final topic in category.topics) ...<Widget>[
                _TopicRow(topic: topic),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              strings('library.sourceNote'),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category, required this.strings});

  final LibraryCategory category;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                category.title,
                style: theme.textTheme.titleMedium,
              ),
            ),
            Text(
              strings.format(
                'library.topicCount',
                <String, Object?>{'total': category.topics.length},
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(category.description, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic});

  final LibraryTopic topic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PressableCard(
      semanticLabel: '${topic.title}. ${topic.summary}',
      onTap: () {
        unawaited(
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (context) => TopicScreen(topicId: topic.id),
            ),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(topic.title, style: theme.textTheme.labelLarge),
                const SizedBox(height: 2),
                Text(topic.summary, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _ContentError extends StatelessWidget {
  const _ContentError({required this.strings, required this.error});

  final AppStrings strings;
  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings('error.contentTitle'),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            strings('error.contentBody'),
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('$error', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
