import 'package:adarsh/constant.dart';
import 'package:flutter/material.dart';
import 'text_field_container.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final Function validator;
  final ValueChanged<String> onChanged;
  final inputType;
  final TextEditingController textEditingController;
  const RoundedInputField(
      {Key key,
      this.hintText,
      this.icon,
      this.onChanged,
      this.inputType = TextInputType.text,
      this.textEditingController,
      this.validator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextContainerField(
      child: TextFormField(
        onChanged: onChanged,
        controller: textEditingController,
        validator: validator,
        decoration: InputDecoration(
            icon: Icon(
              icon,
              color: KPrimaryColor,
            ),
            // errorText: "Hello",
            border: InputBorder.none,
            hintText: hintText),
        keyboardType: inputType,
      ),
    );
  }
}
