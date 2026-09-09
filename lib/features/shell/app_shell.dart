import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../home/home_screen.dart';
import '../iperc/iperc_module_screen.dart';
import '../profile/profile_screen.dart';
import '../progress/progress_screen.dart';
import '../scenarios/scenarios_screen.dart';

/// Contenedor con la navegacion principal.
///
/// Usa [IndexedStack] y no un `PageView`: cambiar de pestana no debe reiniciar
/// el desplazamiento ni el estado de la pestana anterior.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static const List<_ShellTab> _tabs = <_ShellTab>[
    _ShellTab('nav.home', Icons.home_outlined, Icons.home),
    _ShellTab('nav.scenarios', Icons.terrain_outlined, Icons.terrain),
    _ShellTab('nav.iperc', Icons.grid_view_outlined, Icons.grid_view_rounded),
    _ShellTab('nav.progress', Icons.insights_outlined, Icons.insights),
    _ShellTab('nav.profile', Icons.person_outline, Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider).valueOrNull;

    if (strings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const <Widget>[
          HomeScreen(),
          ScenariosScreen(),
          IpercModuleScreen(),
          ProgressScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: _tabs.map((_ShellTab tab) {
          return NavigationDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.selectedIcon),
            label: strings(tab.labelKey),
          );
        }).toList(),
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab(this.labelKey, this.icon, this.selectedIcon);

  final String labelKey;
  final IconData icon;
  final IconData selectedIcon;
}
