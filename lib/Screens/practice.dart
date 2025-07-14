// import 'package:flutter/material.dart';
//
// class practice extends StatelessWidget{
//   @override
//   Widget build(BuildContext context) {
//
//     int days= 30;
//
//
//      return Scaffold(
//        // debugShowCheckedModeBanner: false,
//        appBar: AppBar(
//
//          title: const Center(child: Text("Wellcome to the  app",)),
//        ),
//        body:  Center(
//          child: Column(
//            children: [
//              Text("  Practice page $days",style: TextStyle(
//                    fontSize:40,
//                    color: Colors.purpleAccent,
//                    fontWeight: FontWeight.bold ),
//                ),
//               const SizedBox(
//                height: 20,
//              ),
//              Padding(
//                padding: const EdgeInsets.all(20.0),
//                child: TextField(
//                  decoration: InputDecoration(
//                    border: OutlineInputBorder(),
//                    hintText:("Enter your name ")
//                  ),
//                ),
//              ),
//               const SizedBox(
//                height: 20,
//              ),
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: TextField(
//                  decoration: InputDecoration(
//                    border: OutlineInputBorder(),
//                    hintText:("Enter your password")
//                  ),
//
//                              ),
//               )
//            ],
//          ),
//          ),
//
//
//
//      );
//
//   }
//
// }
//
//
import 'package:flutter/material.dart';

class InputExample extends StatefulWidget {
  InputExample({super.key});

  @override
  State<InputExample> createState() => _InputExampleState();

}

class _InputExampleState extends State<InputExample> {
  TextEditingController _controller=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration:
            InputDecoration(
              hintText: "Enter your  name"
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: (){
            String name =_controller.text;
            print("name, $name"
            );
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("$name")),
    );
            
          }, child:Text('Submit'),
    )
        ],
      ),

    );
  }
}

