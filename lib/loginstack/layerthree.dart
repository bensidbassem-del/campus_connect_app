
// Dart
import 'package:flutter/material.dart';
import 'package:campus_connect_app_login/config.dart';

class LayerThree extends StatefulWidget {
@override
_LayerThreeState createState() => _LayerThreeState();
      }

class _LayerThreeState extends State<LayerThree> {
bool isChecked = false;

@override
Widget build(BuildContext context) {
  // Responsive scaling
  //récupère la largeur de l'écran
final w = MediaQuery.of(context).size.width;
 //largeur de base pour le design
final baseWidth = 375.0;
 //facteur d'échelle
final scale = w / baseWidth;
  // hauteur du conteneur
final containerHeight = 584.0 * scale;

return SizedBox(
   width: w,
   child: SingleChildScrollView(
       child: SizedBox(
         height: containerHeight,
width: w,
child: Stack(
fit: StackFit.expand,
children: <Widget>[
  // Username Label
    Positioned(
left: 59 * scale,
top: 99 * scale,
child: Text(
'Username',
style: TextStyle(
fontFamily: 'Poppins-Medium',
fontSize: 24 * scale,
fontWeight: FontWeight.w500,
),
),
),
// Username TextField
Positioned(
left: 59 * scale,
top: 129 * scale,
child: Container(
width: 310 * scale,
child: TextField(
decoration: InputDecoration(
border: UnderlineInputBorder(),
hintText: 'Enter User ID or Email',
hintStyle: TextStyle(color: hintText, fontSize: 14 * scale),
),
),
),
),
// Password Label
Positioned(
left: 59 * scale,
top: 199 * scale,
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
left: 59 * scale,
top: 229 * scale,
child: Container(
width: 310 * scale,
child: TextField(
obscureText: true,
decoration: InputDecoration(
border: UnderlineInputBorder(),
hintText: 'Enter Password',
hintStyle: TextStyle(color: hintText, fontSize: 14 * scale),
),
),
),
),
//Sign up link
Positioned(
right: 60 * scale,
top: 296 * scale,
child: Text(
'Sign Up',
style: TextStyle(
color: forgotPasswordText,
fontSize: 16 * scale,
fontFamily: 'Poppins-Medium',
fontWeight: FontWeight.w600,
),
),
),
// Remember Me checkbox
Positioned(
left: 46 * scale,
top: 361 * scale,
child: Checkbox(
checkColor: Colors.white,
activeColor: checkbox,
value: isChecked,
onChanged: (bool? value) {
setState(() {
isChecked = value ?? false;
});
},
),
),
// Remember Me text
Positioned(
left: 87 * scale,
top: 375 * scale,
child: Text(
'Remember Me',
style: TextStyle(
color: forgotPasswordText,
fontSize: 16 * scale,
fontFamily: 'Poppins-Medium',
fontWeight: FontWeight.w500,
),
),
),
// Sign In button
Positioned(
top: 365 * scale,
right: 60 * scale,
child: Container(
width: 99 * scale,
height: 35 * scale,
decoration: BoxDecoration(
color: signInButton,
borderRadius: BorderRadius.only(
topLeft: Radius.circular(20 * scale),
bottomRight: Radius.circular(20 * scale),
),
),
alignment: Alignment.center,
child: Text(
'Sign In',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.white,
fontSize: 18 * scale,
fontFamily: 'Poppins-Medium',
fontWeight: FontWeight.w400,
),
),
),
),
// horizontal divider line
Positioned(
top: 432 * scale,
left: 59 * scale,
child: Container(
height: 0.5 * scale,
width: 310 * scale,
color: inputBorder,
),
),
// sign in with google or apple account
Positioned(
top: 462 * scale,
left: 120 * scale,
right: 120 * scale,
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: <Widget>[
Container(
width: 59 * scale,
height: 48 * scale,
decoration: BoxDecoration(
border: Border.all(color: signInBox),
borderRadius: BorderRadius.only(
topLeft: Radius.circular(20 * scale),
bottomRight: Radius.circular(20 * scale),
),
),
child: Image.asset(
'images/icon_google.png',
width: 20 * scale,
height: 21 * scale,
),
),
Text(
'or',
style: TextStyle(
fontSize: 18 * scale,
fontFamily: 'Poppins-Regular',
color: Colors.black,
),
),
Container(
width: 59 * scale,
height: 48 * scale,
decoration: BoxDecoration(
border: Border.all(color: signInBox),
borderRadius: BorderRadius.only(
topLeft: Radius.circular(20 * scale),
bottomRight: Radius.circular(20 * scale),
),
),
    child: Image.asset('images/icon_apple.png',
           width: 20 * scale,
          height: 21 * scale,
    ),
),
],
),
),
                   ],
                 ),
               ),
            ),
          );
       }
  }
class stdCard extends StatelessWidget {
  String name;
  int stdId;
  String btdate;
  String photo;
  String Specialte;
  String Branche;
  int section;
  int groupe;

  stdCard({
    required this.name,
    required this.stdId,
    required this.btdate,
    required this.photo,
    required this.Specialte,
    required this.Branche,
    required this.section,
    required this.groupe,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.35,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.blue[50],
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      _buildInfoRow("ID:", stdId.toString()),
                      _buildInfoRow("Date de naissance:", btdate),
                      _buildInfoRow("Spécialité:", Specialte),
                      _buildInfoRow("Branche:", Branche),
                      _buildInfoRow("Section:", section.toString()),
                      _buildInfoRow("Groupe:", groupe.toString()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        photo,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.blue[700],
          ),
        ),
        SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}
