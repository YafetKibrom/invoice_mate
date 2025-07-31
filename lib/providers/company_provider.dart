import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/company_info.dart';

class CompanyProvider extends ChangeNotifier {
  CompanyInfo? _companyInfo;

  CompanyInfo? get companyInfo => _companyInfo;

  CompanyProvider() {
    loadCompanyInfo();
  }

  Future<void> loadCompanyInfo() async {
    final box = Hive.box<CompanyInfo>('companyInfoBox');
    if (box.isNotEmpty) {
      _companyInfo = box.getAt(0);
      notifyListeners();
    }
  }

  Future<void> saveLogoFile(File logoFile) async {
    if (logoFile.path.isNotEmpty) return;
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/Invoice Maker/.data/logo';

    final dataDir = Directory('${directory.path}/Invoice Maker/.data');
    if (!(await dataDir.exists())) {
      await dataDir.create(recursive: true);
    }
    final savedFile = await logoFile.copy(path);
    print('Logo saved at: ${savedFile.path}');
  }

  Future<void> saveCompanyInfo(CompanyInfo info) async {
    final box = Hive.box<CompanyInfo>('companyInfoBox');
    if (box.isEmpty) {
      await box.add(info);
    } else {
      await box.putAt(0, info);
    }
    _companyInfo = info;
    notifyListeners();
  }

  static Future<void> deleteCompanyInfo(CompanyInfo info) async {
    final box = Hive.box<CompanyInfo>('companyInfoBox');
    box.deleteAt(0);
  }
}
