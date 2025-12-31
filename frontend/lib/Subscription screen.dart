import 'package:flutter/material.dart';


class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}
class _SubscriptionPageState extends State<SubscriptionPage> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    // Responsive scaling
    //récupère la largeur de l'écran
    final w = MediaQuery
        .of(context)
        .size
        .width;
    //largeur de base pour le design
    final baseWidth = 375.0;
    //facteur d'échelle
    final scale = w / baseWidth;
    // hauteur du conteneur
    final containerHeight = 684.0 * scale;

    return SizedBox(
      height: containerHeight,
      width: w,
      child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Full Name Label
            Positioned(
              left: 35 * scale,
              top: 99 * scale,
              child: Text(
                'Full Name',
                style: TextStyle(
                  fontFamily: 'Poppins-Medium',
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Full Name TextField
            Positioned(
              left: 35 * scale,
              top: 129 * scale,
              child: SizedBox(
                width: 310 * scale,
                child: TextField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Enter your full name',
                    hintStyle: TextStyle(color: Colors.white, fontSize: 14 * scale),
                  ),
                ),
              ),
            ),
            // Email Label
            Positioned(
              left: 35 * scale,
              top: 179 * scale,
              child: Text(
                'Email',
                style: TextStyle(
                  fontFamily: 'Poppins-Medium',
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Email TextField
            Positioned(
              left: 35 * scale,
              top: 209 * scale,
              child: SizedBox(
                width: 310 * scale,
                child: TextField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Enter your email address',
                    hintStyle: TextStyle(color: Colors.white, fontSize: 14 * scale),
                  ),
                ),
              ),
            ),
            // Password Label
            Positioned(
              left: 35 * scale,
              top: 259 * scale,
              child: Text(
                'Password',
                style: TextStyle(
                  fontFamily: 'Poppins-Medium',
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Password TextField
            Positioned(
              left: 35 * scale,
              top: 289 * scale,
              child: SizedBox(
                width: 310 * scale,
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(color: Colors.white, fontSize: 14 * scale),
                  ),
                ),
              ),
            ),
          ]),
    );
  }
}