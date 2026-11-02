import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/cubit/auth_cubit.dart';

void main() {
  runApp(const StaffFlowApp());
}

class StaffFlowApp extends StatelessWidget {
  const StaffFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
      ],
      child: MaterialApp.router(
        title: 'StaffFlow HRM',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563EB), // Сучасний синій колір
            background: const Color(0xFFF8FAFC), // Світло-сірий фон замість білого
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            margin: const EdgeInsets.all(16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          dataTableTheme: DataTableThemeData(
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
            dataRowColor: MaterialStateProperty.all(Colors.white),
          ),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}