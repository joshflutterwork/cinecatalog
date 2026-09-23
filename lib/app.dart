import 'package:cinecatalog/core/theme/app_theme.dart';
import 'package:cinecatalog/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CineCatalogApp extends ConsumerWidget {
  const CineCatalogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'CineCatalog',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    routerConfig: ref.watch(appRouterProvider),
  );
}
