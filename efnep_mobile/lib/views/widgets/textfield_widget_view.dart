import 'package:flutter/material.dart';

class TextFieldView extends StatelessWidget {
  final TextEditingController controller;
  final String? labelTxt;
  final String? placeholderTxt;
  final TextInputType? textInputType;
  final String? Function(String?)? validator;

  const TextFieldView({
    Key? key,
    required this.controller,
    this.labelTxt,
    this.placeholderTxt,
    this.textInputType,
    this.validator,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Flexible(
            flex: 1,
            child: SizedBox(
              width: double.infinity,
              
              child: Text(
                labelTxt ?? "",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: TextFormField(
              controller: controller,
              validator: validator,
              maxLines: 1,
              keyboardType: textInputType ?? TextInputType.text,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                // labelStyle:TextStyle(fontSize:14),
                hintText: placeholderTxt,
                hintStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          // ),
        ],
      ),
    );
  }
}
