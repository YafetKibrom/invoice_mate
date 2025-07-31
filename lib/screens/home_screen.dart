import 'package:flutter/material.dart';
import 'client_info_screen.dart';
import 'settings_screen.dart';
import 'previous_invoices_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Icon(Icons.home_filled), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 32,
          children: [
            _buildButton(
              context,
              'New Invoice',
              Icons.note_add_outlined,
              () => _navigate(context, const ClientInfoScreen()),
            ),
            _buildButton(
              context,
              'Saved Invoices',
              Icons.folder_open_outlined,
              () => _navigate(context, const PreviousInvoicesScreen()),
            ),
            _buildButton(
              context,
              'Settings',
              Icons.settings_sharp,
              () => _navigate(context, const SettingsScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    IconData? icon,
    VoidCallback onPressed,
  ) {
    double width = MediaQuery.of(context).size.width;
    double height = 56;
    return SizedBox(
      width: (width / 2).clamp(256, 512),
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.all(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: height - 10),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
