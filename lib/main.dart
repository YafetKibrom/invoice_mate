import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'models/client_info.dart';
import 'models/company_info.dart';
import 'screens/company_info_screen.dart';
import 'screens/home_screen.dart';
import 'providers/company_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final documentsDir = await getApplicationDocumentsDirectory();
  final hiveDir = Directory('${documentsDir.path}\\Invoice Maker\\.data');
  if (!await hiveDir.exists()) {
    await hiveDir.create(recursive: true);
  }
  Hive.init(hiveDir.path);

  Hive.registerAdapter(CompanyInfoAdapter());
  Hive.registerAdapter(ClientInfoAdapter());
  await Hive.openBox<CompanyInfo>('companyInfoBox');
  await Hive.openBox<ClientInfo>('clientsBox');
  await Hive.openBox<String>('contractorsBox');
  runApp(const InvoiceMate());
}

class InvoiceMate extends StatelessWidget {
  const InvoiceMate({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompanyProvider(),
      child: MaterialApp(
        title: 'Invoice App',
        theme: myTheme,
        home: const StartupDecider(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class StartupDecider extends StatelessWidget {
  const StartupDecider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final companyProvider = Provider.of<CompanyProvider>(context);
    if (companyProvider.companyInfo == null) {
      return const CompanyInfoScreen();
    } else {
      return const HomeScreen();
    }
  }
}

class AppColors {
  static Color Primary = const Color.fromARGB(255, 41, 213, 56);
  static Color Secondary = const Color.fromARGB(103, 67, 255, 111);
  static Color Negative = const Color.fromARGB(209, 255, 208, 0);
}

final ThemeData myTheme = ThemeData.dark().copyWith(
  colorScheme: ColorScheme.dark(
    primary: AppColors.Primary,
    onSurface: AppColors.Primary,
    outline: AppColors.Secondary,
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.Primary,
      side: BorderSide(color: AppColors.Primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(2),
      ),
    ),
  ),
);
