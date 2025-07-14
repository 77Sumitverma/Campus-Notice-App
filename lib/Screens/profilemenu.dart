import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class profilemenu extends StatefulWidget {
  const profilemenu({super.key});

  @override
  State<profilemenu> createState() => _profilemenuState();
}

class _profilemenuState extends State<profilemenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(width: 288,height: double.infinity,
          color: Colors.deepPurple,
          child:SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage('lib/assets/images/avtar.png'), // <-- Your profile image path
                  radius: 20,
                ),
                title: Text("Sumit",style: TextStyle(color: Colors.white),
                ),
                subtitle: Text("App dev",style:TextStyle(color: Colors.white),),

              )
            ],
          ),
    )
    ));
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.name, required this.profession});

  final String name,profession;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}







