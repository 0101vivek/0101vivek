import 'package:adarsh/constant.dart';
import 'package:flutter/material.dart';
import 'text_field_container.dart';

class RoundPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController textEditingController;
  final Function validator;
  final inputType;
  // final bool isPassword;
  const RoundPasswordField({
    Key key,
    this.onChanged,
    this.validator,
    this.textEditingController,
    this.inputType = TextInputType.text,
  }) : super(key: key);

  @override
  _RoundPasswordFieldState createState() => _RoundPasswordFieldState();
}

class _RoundPasswordFieldState extends State<RoundPasswordField> {
  bool isPassword = true;
  @override
  Widget build(BuildContext context) {
    return TextContainerField(
      child: TextFormField(
        obscureText: isPassword,
        onChanged: widget.onChanged,
        controller: widget.textEditingController,
        validator: widget.validator,
        keyboardType: widget.inputType,
        decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.lock,
            color: KPrimaryColor,
          ),
          suffix: InkWell(
            onTap: () {
              setState(() {
                isPassword = !isPassword;
              });
            },
            child: Icon(
              isPassword ? Icons.visibility : Icons.visibility_off,
              color: KPrimaryColor,
            ),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
