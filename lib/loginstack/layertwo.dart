import 'package:flutter/material.dart';
import 'package:campus_connect_app_login/config.dart';

class LayerTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 584,
      decoration: BoxDecoration(
        color: layerTwoBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(60.0),
          bottomRight: Radius.circular(60.0),
          bottomLeft: Radius.circular(60.0),
        ),
      ),
    );
  }
}