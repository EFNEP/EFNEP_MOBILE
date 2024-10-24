import 'package:flutter/material.dart';

class InputWithIcon extends StatefulWidget {
  final IconData btnIcon;
  final String hintText;
  final TextEditingController myController;
  final String? Function(String?) validateFunc;
  final bool obscure;
  final TextInputType keyboardType;
  const InputWithIcon({
    Key? key,
    required this.btnIcon,
    required this.hintText,
    required this.myController,
    required this.validateFunc,
    required this.obscure,
    required this.keyboardType,
  }) : super(key: key);

  @override
  State<InputWithIcon> createState() => _InputWithIconState();
}

class _InputWithIconState extends State<InputWithIcon> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 60,
            child: Icon(
              widget.btnIcon,
              size: 20,
              color: Colors.grey.shade500,
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 50,
              child: TextFormField(
                key: widget.key,
                decoration: InputDecoration(
                  errorStyle: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                autocorrect: false,
                controller: widget.myController,
                validator: widget.validateFunc,
                obscureText: widget.obscure,
                keyboardType: widget.keyboardType,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
