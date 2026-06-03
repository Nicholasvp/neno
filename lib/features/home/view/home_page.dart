import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_theme.dart';
import '../../ai/bloc/ai_bloc.dart';
import '../../ai/bloc/ai_event.dart';
import '../../ai/view/ai_advice_page.dart';
import '../../analytics/bloc/analytics_bloc.dart';
import '../../analytics/bloc/analytics_event.dart';
import '../../analytics/view/analytics_page.dart';
import '../../movements/bloc/movements_bloc.dart';
import '../../movements/bloc/movements_event.dart';
import '../../movements/view/movements_page.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_event.dart';
import '../../profile/bloc/profile_state.dart';
import '../../profile/view/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    context.read<MovementsBloc>().add(const MovementsSubscribed());
    context.read<AnalyticsBloc>().add(const AnalyticsSubscribed());
    context.read<ProfileBloc>().add(const ProfileLoaded());
    _syncAiContext();
  }

  void _syncAiContext() {
    final ai = context.read<AiBloc>();
    final profileState = context.read<ProfileBloc>().state;
    final movements = context.read<MovementsBloc>().state.movements;
    ai.add(AiContextUpdated(
      profile: profileState.profile,
      movements: movements,
    ));
  }

  void _onTabChange(int i) {
    setState(() => _index = i);
    if (i == 2) _syncAiContext();
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [
      MovementsPage(),
      AnalyticsPage(),
      AiAdvicePage(),
      ProfilePage(),
    ];
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (a, b) => a.profile != b.profile,
      listener: (_, __) => _syncAiContext(),
      child: Scaffold(
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _onTabChange,
          indicatorColor: AppTheme.accent,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite, color: AppTheme.primary),
              label: 'Movimentos',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart, color: AppTheme.primary),
              label: 'Análises',
            ),
            NavigationDestination(
              icon: Icon(Icons.psychology_alt_outlined),
              selectedIcon: Icon(Icons.psychology_alt, color: AppTheme.primary),
              label: 'Conselhos',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppTheme.primary),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
