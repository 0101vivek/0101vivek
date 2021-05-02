import 'package:flutter/material.dart';

// ignore: camel_case_types
class Flat_Button extends StatefulWidget {
  final Function onpress;
  final String text;
  final Color color, textColor;
  const Flat_Button(
      {Key key, this.onpress, this.color, this.textColor, this.text})
      : super(key: key);

  @override
  _FlatButtonState createState() => _FlatButtonState();
}

class _FlatButtonState extends State<Flat_Button> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        // margin: EdgeInsets.symmetric(vertical: 0),
        width: size.width,
        alignment: Alignment.topLeft,
        child: FlatButton(
          // padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          color: this.widget.color,
          onPressed: widget.onpress,
          child: Text(
            this.widget.text,
            style: TextStyle(color: this.widget.textColor, fontSize: 15),
          ),
        ));
  }
}
