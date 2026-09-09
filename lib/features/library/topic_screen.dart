import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/flow/app_flow_controller.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/library/library_repository.dart';
import '../../domain/library/library_content.dart';
import 'widgets/technical_diagrams.dart';

/// Ficha de la biblioteca.
///
/// Orden fijo: concepto, diagrama, aplicacion en operacion y comprobacion.
/// El ejemplo minero va siempre despues de la teoria y antes de la pregunta,
/// porque es lo que ancla el concepto a algo que el estudiante reconoce.
class TopicScreen extends ConsumerWidget {
  const TopicScreen({required this.topicId, super.key});

  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider).valueOrNull;
    final content = ref.watch(libraryContentProvider).valueOrNull;

    if (strings == null || content == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final topic = content.topicById(topicId);
    if (topic == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(strings('error.contentTitle'))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: <Widget>[
          Text(topic.summary, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.lg),
          for (final section in topic.sections) ...<Widget>[
            Text(section.heading, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(section.body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (topic.diagram != null) ...<Widget>[
            TechnicalDiagram(id: topic.diagram!, strings: strings),
            const SizedBox(height: AppSpacing.lg),
          ],
          _ExampleCard(
            title: strings('topic.exampleTitle'),
            body: topic.miningExample,
          ),
          if (topic.check != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            CheckQuestionCard(
              topicId: topic.id,
              question: topic.check!,
              strings: strings,
            ),
          ],
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Pregunta de comprobacion.
///
/// Muestra la explicacion tanto si se acierta como si no. La explicacion es
/// el contenido de la pregunta, no la recompensa por acertar: quien acerto
/// por eliminacion tambien necesita leer por que.
class CheckQuestionCard extends ConsumerStatefulWidget {
  const CheckQuestionCard({
    required this.topicId,
    required this.question,
    required this.strings,
    super.key,
  });

  final String topicId;
  final CheckQuestion question;
  final AppStrings strings;

  @override
  ConsumerState<CheckQuestionCard> createState() => _CheckQuestionCardState();
}

class _CheckQuestionCardState extends ConsumerState<CheckQuestionCard> {
  /// Respuesta de esta visita. Nula mientras no se haya tocado nada.
  int? _selected;

  int? _current(bool completed) {
    if (_selected != null) {
      return _selected;
    }
    // Una ficha ya superada se reabre resuelta, con la explicacion visible.
    // Antes esto vivia solo en el estado del widget, asi que al salir de la
    // pantalla se perdia y la pregunta reaparecia sin responder.
    return completed ? widget.question.correctIndex : null;
  }

  void _answer(int index) {
    setState(() => _selected = index);
    if (widget.question.isCorrect(index)) {
      unawaited(
        ref.read(appFlowProvider.notifier).markTopicCompleted(widget.topicId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = widget.question;
    final flow = ref.watch(appFlowProvider);
    final completed = flow.completedTopics.contains(widget.topicId);

    final selected = _current(completed);
    final answered = selected != null;
    final isCorrect = selected != null && question.isCorrect(selected);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.strings('topic.checkTitle'),
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(question.prompt, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          for (int i = 0; i < question.options.length; i++) ...<Widget>[
            _Option(
              text: question.options[i],
              state: _stateFor(i, selected),
              onTap: answered ? null : () => _answer(i),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (answered) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: <Widget>[
                Icon(
                  isCorrect ? Icons.check_circle_outline : Icons.info_outline,
                  size: 18,
                  color: isCorrect ? AppColors.riskLow : AppColors.riskMedium,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  isCorrect
                      ? widget.strings('topic.checkCorrect')
                      : widget.strings('topic.checkIncorrect'),
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(question.explanation, style: theme.textTheme.bodyMedium),
            if (!isCorrect) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _selected = null),
                  child: Text(widget.strings('topic.checkAgain')),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  _OptionState _stateFor(int index, int? selected) {
    if (selected == null) {
      return _OptionState.idle;
    }
    if (widget.question.isCorrect(index)) {
      return _OptionState.correct;
    }
    return index == selected ? _OptionState.wrong : _OptionState.idle;
  }
}

enum _OptionState { idle, correct, wrong }

class _Option extends StatelessWidget {
  const _Option({
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color border;
    switch (state) {
      case _OptionState.idle:
        border = AppColors.textSecondary.withValues(alpha: 0.35);
      case _OptionState.correct:
        border = AppColors.riskLow;
      case _OptionState.wrong:
        border = AppColors.riskHigh;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            border: Border.all(
              color: border,
              width: state == _OptionState.idle ? 1 : 2,
            ),
          ),
          child: Text(text, style: theme.textTheme.bodyMedium),
        ),
      ),
    );
  }
}
