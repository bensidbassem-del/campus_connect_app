import 'package:flutter/material.dart';

class TeacherScreen extends StatefulWidget{
  const TeacherScreen({super.key});

  @override
  _TeacherScreenState createState() => _TeacherScreenState();
}
class _TeacherScreenState extends State<TeacherScreen>{
  @override
  Widget build(BuildContext context){
    return DefaultTabController
      (length: 3,
      child: Scaffold
        (appBar: AppBar(
        foregroundColor: Colors.white,

        bottom: TabBar(

          labelColor: Colors.cyan[400],

          unselectedLabelColor: Colors.grey[300],

          indicatorColor: Colors.cyanAccent[400],

          tabs: const [
            Tab(icon: Icon(Icons.folder)),
            Tab(icon: Icon(Icons.person)),
            Tab(icon: Icon(Icons.grade)),
          ],
        ),
      ),
          body:TabBarView(
              children:[
                Center(child:Text('this is Courses page')),
                Center(child:Text('Here is Attendance page')
                ),
                Center(
                    child:Text('this is Marks page')
                ),
              ]
          )
      ),
    );
  }
}