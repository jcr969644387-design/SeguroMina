import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/flow/app_flow_controller.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../library/widgets/technical_diagrams.dart';

/// Onboarding de tres pantallas.
///
/// Explica el ciclo que estructura toda la app —observar, evaluar, decidir—
/// antes de que el estudiante entre al primer escenario. Se puede omitir:
/// obligar a leer tres pantallas antes de tocar nada es la forma mas rapida
/// de que se salten la informacion.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const List<_OnboardingPage> _pages = <_OnboardingPage>[
    _OnboardingPage(
      titleKey: 'onboarding.observe.title',
      bodyKey: 'onboarding.observe.body',
      diagram: 'hazard_vs_risk',
    ),
    _OnboardingPage(
      titleKey: 'onboarding.evaluate.title',
      bodyKey: 'onboarding.evaluate.body',
      diagram: 'risk_matrix',
    ),
    _OnboardingPage(
      titleKey: 'onboarding.decide.title',
      bodyKey: 'onboarding.decide.body',
      diagram: 'control_hierarchy',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _page == _pages.length - 1;

  Future<void> _finish() async {
    await ref.read(appFlowProvider.notifier).completeOnboarding();
  }

  Future<void> _advance() async {
    if (_isLast) {
      await _finish();
      return;
    }
    await _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider).valueOrNull;
    if (strings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(strings('onboarding.skip')),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingPageView(
                    page: page,
                    title: strings(page.titleKey),
                    body: strings(page.bodyKey),
                    strings: strings,
                  );
                },
              ),
            ),
            _PageDots(count: _pages.length, active: _page),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: FilledButton(
                onPressed: _advance,
                child: Text(
                  _isLast
                      ? strings('onboarding.start')
                      : strings('onboarding.next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.titleKey,
    required this.bodyKey,
    required this.diagram,
  });

  final String titleKey;
  final String bodyKey;

  /// Diagrama tecnico que ilustra la pantalla. Son los mismos que usa la
  /// biblioteca: el onboarding adelanta contenido real, no decoracion.
  final String diagram;
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({
    required this.page,
    required this.title,
    required this.body,
    required this.strings,
  });

  final _OnboardingPage page;
  final String title;
  final String body;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: AppSpacing.md),
          TechnicalDiagram(id: page.diagram, strings: strings),
          const SizedBox(height: AppSpacing.xl),
          Text(title, style: theme.textTheme.displaySmall),
          const SizedBox(height: AppSpacing.md),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (index) {
        final isActive = index == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          height: 8,
          width: isActive ? 26 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
