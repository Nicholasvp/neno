import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/service_locator.dart';
import '../data/repositories/ai_repository.dart';
import '../data/repositories/movement_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../features/ai/bloc/ai_bloc.dart';
import '../features/analytics/bloc/analytics_bloc.dart';
import 'splash/splash_page.dart';
import '../features/movements/bloc/movements_bloc.dart';
import '../features/profile/bloc/profile_bloc.dart';
import 'theme/app_theme.dart';

class NenoApp extends StatelessWidget {
  const NenoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MovementsBloc(repository: sl<MovementRepository>()),
        ),
        BlocProvider(
          create: (_) => AnalyticsBloc(repository: sl<MovementRepository>()),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(repository: sl<ProfileRepository>()),
        ),
        BlocProvider(
          create: (_) => AiBloc(
            aiRepository: sl<AiRepository>(),
            movementRepository: sl<MovementRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Neno',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        localizationsDelegates: const [],
        home: const SplashPage(),
      ),
    );
  }
}
