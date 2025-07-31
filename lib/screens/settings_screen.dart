import 'dart:io';

import 'package:flutter/material.dart';
import '/screens/company_info_screen.dart';
import '/widgets/image_picker_widget.dart';
import 'package:provider/provider.dart';

import '../models/company_info.dart';
import '../providers/company_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _phoneController;
  late TextEditingController _rateController;
  String logoPath = '';

  bool hasLogo = false;

  @override
  void initState() {
    super.initState();
    final company = context.read<CompanyProvider>().companyInfo;
    logoPath = company!.logoPath!;

    _nameController = TextEditingController(text: company.name);
    _addressController = TextEditingController(text: company.address);
    _cityController = TextEditingController(text: company.city);
    _postalCodeController = TextEditingController(text: company.postalCode);
    _phoneController = TextEditingController(text: company.phoneNumber);
    _rateController = TextEditingController(
      text: company.defaultRate.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _saveCompanyInfo() {
    if (_formKey.currentState!.validate()) {
      final newCompany = CompanyInfo(
        name: _nameController.text,
        address: _addressController.text,
        city: _cityController.text,
        postalCode: _postalCodeController.text,
        phoneNumber: _phoneController.text,
        defaultRate: double.tryParse(_rateController.text) ?? 0,
        logoPath: logoPath,
      );
      context.read<CompanyProvider>().saveCompanyInfo(newCompany);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Company info updated')));
    }
  }

  void _resetCompanyInfo() async {
    final company = context.read<CompanyProvider>().companyInfo;
    await CompanyProvider.deleteCompanyInfo(company!);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => CompanyInfoScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Company Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter company name'
                    : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter address'
                    : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter city' : null,
              ),
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(labelText: 'Postal Code'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter postal code'
                    : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter phone number'
                    : null,
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(labelText: 'Default Rate'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter default rate';
                  final rate = double.tryParse(value);
                  if (rate == null) return 'Please enter a valid number';
                  if (rate < 0) return 'Rate cannot be negative';
                  return null;
                },
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              if (logoPath.isNotEmpty)
                Image.file(File(logoPath), width: 128, height: 128),
              ImagePickerWidget(
                size: 0,
                onImagePicked: (image) {
                  setState(() {
                    logoPath = image.path;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveCompanyInfo,
                child: const Text('Save Company Info'),
              ),
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),
              const Text(
                'Reset Company Info',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'This will clear saved company information and you will be asked to enter it again on next app start.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _resetCompanyInfo,
                child: const Text('Reset Company Info'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
