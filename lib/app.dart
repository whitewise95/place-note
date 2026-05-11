import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/address_analysis_repository.dart';
import 'data/repositories/local_address_analysis_repository.dart';
import 'features/capture/capture_screen.dart';
import 'features/history/history_screen.dart';
import 'features/home_screen.dart';

class AddressResearchApp extends StatefulWidget {
  const AddressResearchApp({super.key});

  @override
  State<AddressResearchApp> createState() => _AddressResearchAppState();
}

class _AddressResearchAppState extends State<AddressResearchApp> {
  late final AddressAnalysisRepository repository;

  @override
  void initState() {
    super.initState();
    // TODO(server): 서버 연동 시 RemoteAddressAnalysisRepository로 교체한다.
    repository = LocalAddressAnalysisRepository();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryScope(
      repository: repository,
      child: MaterialApp(
        title: 'Place Note',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routes: {
          HomeScreen.routeName: (_) => const HomeScreen(),
          CaptureScreen.routeName: (_) => const CaptureScreen(),
          HistoryScreen.routeName: (_) => const HistoryScreen(),
        },
        initialRoute: HomeScreen.routeName,
      ),
    );
  }
}

class RepositoryScope extends InheritedWidget {
  const RepositoryScope({
    required this.repository,
    required super.child,
    super.key,
  });

  final AddressAnalysisRepository repository;

  static AddressAnalysisRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RepositoryScope>();
    assert(scope != null, 'RepositoryScope not found');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(RepositoryScope oldWidget) {
    return repository != oldWidget.repository;
  }
}
