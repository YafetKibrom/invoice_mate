import 'package:flutter/material.dart';

import '../main.dart';

// ignore: must_be_immutable
class AutoCompleteTextField extends StatefulWidget {
  final List<String> options;
  final void Function(String)? onSelected;
  final VoidCallback? onClear;
  String? labelText;
  double fontSize;
  TextEditingController controller;

  AutoCompleteTextField({
    required this.options,
    required this.labelText,
    required this.controller,
    this.onSelected,
    this.onClear,
    this.fontSize = 24,
  });

  @override
  State<AutoCompleteTextField> createState() => _AutoCompleteTextFieldState();
}

class _AutoCompleteTextFieldState extends State<AutoCompleteTextField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue value) {
        return widget.options.where(
          (option) => option.toLowerCase().startsWith(value.text.toLowerCase()),
        );
      },
      onSelected: widget.onSelected,
      fieldViewBuilder:
          (context, fieldController, focusNode, onFieldSubmitted) {
            return Stack(
              alignment: Alignment.centerRight,
              children: [
                TextFormField(
                  style: TextStyle(fontSize: widget.fontSize),
                  controller: fieldController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: widget.labelText,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    widget.controller.text = value;
                    widget.controller.selection = TextSelection.collapsed(
                      offset: fieldController.text.length,
                    );
                  },
                ),
                IconButton(
                  onPressed: () {
                    fieldController.clear();
                    if (widget.onClear != null) widget.onClear!();
                  },
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(0),
                    ),
                  ),
                  icon: FittedBox(
                    child: Icon(
                      Icons.clear,
                      color: AppColors.Negative,
                      size: widget.fontSize * 1.75,
                    ),
                  ),
                ),
              ],
            );
          },
    );
  }
}
