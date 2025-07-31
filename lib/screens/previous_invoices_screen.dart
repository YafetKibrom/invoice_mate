import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'invoice_preview_screen.dart';

class PreviousInvoicesScreen extends StatefulWidget {
  const PreviousInvoicesScreen({Key? key}) : super(key: key);

  @override
  State<PreviousInvoicesScreen> createState() => _PreviousInvoicesScreenState();
}

class _PreviousInvoicesScreenState extends State<PreviousInvoicesScreen> {
  Directory? _rootDir;
  Directory? _currentDir;
  List<FileSystemEntity> _entities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initRootDir();
  }

  Future<void> _initRootDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final invoicesDir = Directory('${dir.path}/Invoices');

    if (!await invoicesDir.exists()) {
      await invoicesDir.create(recursive: true);
    }

    setState(() {
      _rootDir = invoicesDir;
      _currentDir = invoicesDir;
    });

    await _loadEntities();
  }

  Future<void> _loadEntities() async {
    if (_currentDir == null) return;

    setState(() => _isLoading = true);

    final entities = _currentDir!.listSync()
      ..sort((a, b) {
        if (a is Directory && b is File) return -1;
        if (a is File && b is Directory) return 1;
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });

    setState(() {
      _entities = entities;
      _isLoading = false;
    });
  }

  void _openEntity(FileSystemEntity entity) {
    if (entity is Directory) {
      setState(() {
        _currentDir = entity;
      });
      _loadEntities();
    } else if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InvoicePreviewScreen(filePath: entity.path),
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentDir == null || _currentDir == _rootDir) {
      return true; // Exit screen
    }

    setState(() {
      _currentDir = _currentDir!.parent;
    });
    await _loadEntities();
    return false; // Prevent exit, just go up folder
  }

  String _getFolderName(Directory dir) {
    return dir.path.split(Platform.pathSeparator).last;
  }

  @override
  Widget build(BuildContext context) {
    final currentFolderName = _currentDir == null
        ? ''
        : _getFolderName(_currentDir!);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            currentFolderName.isEmpty ? 'Invoices' : currentFolderName,
          ),
          centerTitle: true,
          leading: _currentDir == null || _currentDir == _rootDir
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    if (await _onWillPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _entities.isEmpty
            ? const Center(child: Text('No files or folders found.'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _entities.length,
                itemBuilder: (context, index) {
                  final entity = _entities[index];
                  final name = entity.path.split(Platform.pathSeparator).last;
                  final isDir = entity is Directory;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      leading: Icon(
                        isDir ? Icons.folder : Icons.picture_as_pdf,
                        color: isDir ? Colors.amber.shade700 : Colors.redAccent,
                        size: 36,
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => _openEntity(entity),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
