import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/pressable_card.dart';
import '../../data/library/library_repository.dart';
import '../../domain/library/library_content.dart';
import '../../domain/training/risk_level.dart';
import '../library/topic_screen.dart';
import '../library/widgets/technical_diagrams.dart';

/// Modulo IPERC.
///
/// Reune en una pestana el proceso completo: la secuencia, la matriz
/// normativa con sus plazos de correccion y las fichas que explican cada
/// paso. Es la parte de la app que un estudiante consultara mientras llena
/// un IPERC continuo de verdad, asi que la matriz esta arriba y accesible.
class IpercModuleScreen extends ConsumerWidget {
  const IpercModuleScreen({super.key});

  static const String categoryId = 'iperc';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider).valueOrNull;
    final content = ref.watch(libraryContentProvider).valueOrNull;

    if (strings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final category = content?.categoryById(categoryId);

    return Scaffold(
      appBar: AppBar(title: Text(strings('nav.iperc'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: <Widget>[
          Text(
            strings('iperc.moduleSubtitle'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            strings('iperc.processTitle'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          IpercFlowDiagram(strings: strings),
          const SizedBox(height: AppSpacing.lg),
          Text(
            strings('iperc.matrixTitle'),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          RiskMatrixDiagram(strings: strings),
          const SizedBox(height: AppSpacing.sm),
          const _DeadlineTable(),
          const SizedBox(height: AppSpacing.lg),
          if (category != null) ...<Widget>[
            Text(
              strings('iperc.topicsTitle'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final topic in category.topics) ...<Widget>[
              _TopicRow(topic: topic),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            strings('library.sourceNote'),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Plazos de correccion por nivel de riesgo.
///
/// Van junto a la matriz porque son la mitad util del resultado: saber que un
/// riesgo es Alto no dice nada si no se sabe que hay 24 horas para corregirlo
/// y que la labor no se opera mientras tanto.
class _DeadlineTable extends ConsumerWidget {
  const _DeadlineTable();

  Color _color(RiskLevel level) {
    switch (level) {
      case RiskLevel.alto:
        return AppColors.riskHigh;
      case RiskLevel.medio:
        return AppColors.riskMedium;
      case RiskLevel.bajo:
        return AppColors.riskLow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider).valueOrNull;
    if (strings == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: <Widget>[
        for (final level in <RiskLevel>[
          RiskLevel.alto,
          RiskLevel.medio,
          RiskLevel.bajo,
        ]) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border(
                left: BorderSide(color: _color(level), width: 3),
              ),
              color: _color(level).withValues(alpha: 0.08),
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 54,
                  child: Text(
                    strings(level.rangeKey),
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                Expanded(
                  child: Text(
                    strings(level.labelKey),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: Text(
                    strings(level.deadlineKey),
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
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
