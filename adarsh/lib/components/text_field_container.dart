import 'package:adarsh/constant.dart';
import 'package:flutter/material.dart';

class TextContainerField extends StatelessWidget {
  final Widget child;

  const TextContainerField({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.fromLTRB(10, 20, 6, 20),
      width: size.width * 0.9,
      height: size.height * 0.1,
      decoration: BoxDecoration(
        color: KPrimaryLightColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: child,
    );
  }
}
