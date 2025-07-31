import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/main.dart';
import '/models/client_info.dart';
import '/providers/company_provider.dart';
import '/widgets/auto_complete_text_field.dart';
import '../models/ticket.dart';
import '../providers/contractor_provider.dart';
import 'invoice_preview_screen.dart';

class TicketEntryScreen extends StatefulWidget {
  final ClientInfo clientInfo;
  const TicketEntryScreen({Key? key, required this.clientInfo})
    : super(key: key);

  @override
  State<TicketEntryScreen> createState() => _TicketEntryScreenState();
}

class _TicketEntryScreenState extends State<TicketEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _dateController = TextEditingController();
  final _ticketNumberController = TextEditingController();
  final _contractorController = TextEditingController();
  final _locationsController = TextEditingController();
  final _loadsController = TextEditingController();
  final _hoursController = TextEditingController();
  final _rateController = TextEditingController();

  List<Ticket> _tickets = [];
  List<String> _contractors = [];

  @override
  void initState() {
    super.initState();
    setDefaultRate();
  }

  void setDefaultRate() async {
    final provider = await CompanyProvider();
    _rateController.text = provider.companyInfo!.defaultRate.toString();
    _contractors = await ContractorProvider.loadContractors();
    setState(() {
      _contractors.sort();
    });
    if (_contractors.isNotEmpty)
      _contractorController.text = _contractors.first;
  }

  @override
  void dispose() {
    _ticketNumberController.dispose();
    _contractorController.dispose();
    _locationsController.dispose();
    _loadsController.dispose();
    _hoursController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _addTicket() {
    saveContractor();
    if (_formKey.currentState!.validate()) {
      final ticket = Ticket(
        date: _dateController.text,
        ticketNumber: _ticketNumberController.text.trim(),
        contractor: _contractorController.text.trim(),
        locations: _locationsController.text.trim(),
        loads: _loadsController.text,
        hours: double.parse(_hoursController.text.trim()),
        rate: double.parse(_rateController.text.trim()),
      );
      setState(() {
        setDefaultRate();
        _tickets.add(ticket);
        _ticketNumberController.clear();
        _locationsController.clear();
        _loadsController.clear();
        _hoursController.clear();

        _tickets.sort((a, b) {
          final DateTime dateA = DateFormat('dd-MM-yyyy').parse(a.date);
          final DateTime dateB = DateFormat('dd-MM-yyyy').parse(b.date);
          return dateA.compareTo(dateB);
        });
      });
    }
  }

  void saveContractor() async {
    await ContractorProvider.addContractor(_contractorController.text);
  }

  void _finish() {
    if (_tickets.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add at least one ticket')));
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => InvoicePreviewScreen(
          clientName: widget.clientInfo.name,
          clientAddress: widget.clientInfo.address,
          clientCity: widget.clientInfo.city,
          clientPostalCode: widget.clientInfo.postalCode,
          clientPhone: widget.clientInfo.phoneNumber,
          tickets: _tickets,
        ),
      ),
    );
  }

  void formatDate(String val) {
    String Modified = _dateController.text;
    if (val.length == 3 && Modified[2] != '-') {
      Modified = Modified.substring(0, 2) + '-' + Modified[2];
      _dateController.text = Modified;
      _dateController.selection = TextSelection.collapsed(
        offset: Modified.length,
      );
    }
    if (val.length == 6 && Modified[5] != '-') {
      Modified = Modified.substring(0, 5) + '-' + Modified[5];
      _dateController.text = Modified;
      _dateController.selection = TextSelection.collapsed(
        offset: Modified.length,
      );
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int? charLimit = null,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? Function(String?)? onChange,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        maxLength: charLimit,
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChange,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          counterText: '',
        ),
        validator:
            validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
      ),
    );
  }

  bool isValidDate(String input, String format) {
    try {
      DateFormat(format).parseStrict(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  void editTicket(Ticket ticket, int index) {
    setState(() {
      _dateController.text = ticket.date.toString();
      _ticketNumberController.text = ticket.ticketNumber;
      _contractorController.text = ticket.contractor;
      _locationsController.text = ticket.locations;
      _loadsController.text = ticket.loads;
      _hoursController.text = ticket.hours.toString();
      _rateController.text = ticket.rate.toString();
      _tickets.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Entry'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                _dateController,
                'Date (DD-MM-YYYY)',
                keyboardType: TextInputType.datetime,
                charLimit: 10,
                onChange: (val) {
                  formatDate(val!);
                  return null;
                },
                validator: (value) {
                  if (isValidDate(value!, 'dd-MM-yyyy') == false)
                    return 'Please Enter Valid Date';
                  return null;
                },
              ),
              _buildTextField(
                _ticketNumberController,
                'Ticket Number',
                keyboardType: TextInputType.numberWithOptions(),
              ),
              AutoCompleteTextField(
                controller: _contractorController,
                options: _contractors,
                labelText: 'Contractor',
                fontSize: 18,
                onSelected: (val) => _contractorController.text = val,
              ),
              SizedBox(height: 12),
              _buildTextField(_locationsController, 'Locations'),
              _buildTextField(
                _loadsController,
                'Loads',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Please enter Loads';
                  return null;
                },
              ),
              _buildTextField(
                _hoursController,
                'Hours',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Please enter Hours';
                  if (double.tryParse(value.trim()) == null)
                    return 'Enter valid number';
                  return null;
                },
              ),
              _buildTextField(
                _rateController,
                'Rate',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Please enter Rate';
                  if (double.tryParse(value.trim()) == null)
                    return 'Enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addTicket,
                      child: const Text('Add Ticket'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _finish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Finish'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_tickets.isNotEmpty) ...[
                const Text(
                  'Tickets Added:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tickets.length,
                  itemBuilder: (context, index) {
                    final t = _tickets[index];
                    return SizedBox(
                      width: screenWidth - 64,
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(
                                '${t.ticketNumber} - ${t.contractor}',
                              ),
                              subtitle: Text(
                                'Date: ${t.date} | Loads: ${t.loads} | Hours: ${t.hours} | Rate: ${t.rate} | Total: ${t.total.toStringAsFixed(2)}',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              editTicket(t, index);
                            },
                            icon: Icon(Icons.edit, color: AppColors.Primary),
                            iconSize: 32,
                          ),
                          // IconButton(
                          //   onPressed: () {
                          //     setState(() {
                          //       for (int i = 0; i < 8; i++) _tickets.add(t);
                          //     });
                          //   },
                          //   icon: Icon(
                          //     Icons.copy_sharp,
                          //     color: Colors.lightGreen,
                          //   ),
                          //   iconSize: 32,
                          // ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
