import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class ImagePickerWidget extends StatefulWidget {
  final double size;
  void Function(File image)? onImagePicked;
  ImagePickerWidget({this.size = 32, this.onImagePicked});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _imageFile = null;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        widget.onImagePicked!(_imageFile!);
      });
    } else {
      // User canceled or no image picked
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_imageFile != null)
          Image.file(
            _imageFile!,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
          ),
        const SizedBox(height: 10),
        ElevatedButton(onPressed: _pickImage, child: const Text('Pick Image')),
      ],
    );
  }
}
