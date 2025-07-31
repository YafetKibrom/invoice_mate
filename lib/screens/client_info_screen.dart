import 'package:flutter/material.dart';
import '/models/client_info.dart';
import '/providers/client_provider.dart';
import '/widgets/auto_complete_text_field.dart';

import 'ticket_entry_screen.dart';

class ClientInfoScreen extends StatefulWidget {
  const ClientInfoScreen({super.key});

  @override
  State<ClientInfoScreen> createState() => _ClientInfoScreenState();
}

class _ClientInfoScreenState extends State<ClientInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();

  List<String> clientNames = [];

  @override
  void initState() {
    super.initState();
    setClientNames();
  }

  void setClientNames() async {
    List<String> names = await ClientsProvider.loadClientNames();
    setState(() {
      clientNames = names;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void autoFillClientInfo(String name) async {
    ClientInfo? info = await ClientsProvider.loadClientInfo(name);
    _nameController.text = name;
    _addressController.text = info!.address;
    _cityController.text = info.city;
    _postalCodeController.text = info.postalCode;
    _phoneController.text = info.phoneNumber;
  }

  void _next() async {
    if (_formKey.currentState!.validate()) {
      ClientInfo clientInfo = ClientInfo(
        name: _nameController.text,
        address: _addressController.text,
        city: _cityController.text,
        postalCode: _postalCodeController.text,
        phoneNumber: _phoneController.text,
      );

      await ClientsProvider.addClientInfo(clientInfo);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TicketEntryScreen(clientInfo: clientInfo),
        ),
      );
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      style: TextStyle(fontSize: 20),
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
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Info'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 12,
            children: [
              AutoCompleteTextField(
                options: clientNames,
                labelText: 'Name',
                controller: _nameController,
                fontSize: 20,
                onSelected: (val) => autoFillClientInfo(val),
              ),
              _buildTextField(_addressController, 'Address'),
              _buildTextField(_cityController, 'City'),
              _buildTextField(_postalCodeController, 'Postal Code'),
              _buildTextField(
                _phoneController,
                'Phone Number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 256,
                child: OutlinedButton(
                  onPressed: _next,
                  child: const Text('Next', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
