import 'dart:io';

import 'package:flutter/material.dart';
import '/widgets/image_picker_widget.dart';
import 'package:provider/provider.dart';

import '../models/company_info.dart';
import '../providers/company_provider.dart';
import 'home_screen.dart';

class CompanyInfoScreen extends StatefulWidget {
  const CompanyInfoScreen({super.key});

  @override
  State<CompanyInfoScreen> createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends State<CompanyInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rateController = TextEditingController();
  File? logoImage;

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

  void _saveCompanyInfo() async {
    if (_formKey.currentState!.validate()) {
      final info = CompanyInfo(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        defaultRate: double.parse(_rateController.text.trim()),
        logoPath: logoImage!.path,
      );

      final provider = Provider.of<CompanyProvider>(context, listen: false);
      await provider.saveCompanyInfo(info);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Company Info'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Company Name', false),
              _buildTextField(_addressController, 'Address', false),
              _buildTextField(_cityController, 'City', false),
              _buildTextField(_postalCodeController, 'Postal Code', false),
              _buildTextField(
                _phoneController,
                'Phone Number',
                false,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                _rateController,
                'Default Rate',
                true,
                keyboardType: TextInputType.number,
              ),
              ImagePickerWidget(
                size: 128,
                onImagePicked: (image) {
                  logoImage = image;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCompanyInfo,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool isNumber, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          if (isNumber && double.tryParse(value.trim()) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}
