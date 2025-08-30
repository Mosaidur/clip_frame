import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashBoardPage extends StatelessWidget {
  // final BusinessTypeSelectionController controller = Get.put(BusinessTypeSelectionController());
  final TextEditingController customTypeController = TextEditingController();
  String date = 'March 25, 2024';


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB49EF4), Color(0xFFEBC894)],
        ),
      ),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
             Container (
               width: double.infinity,

               decoration: BoxDecoration(
                 color: Colors.white.withOpacity(0.4),
                 borderRadius: BorderRadius.only(
                   bottomLeft: Radius.circular(30),bottomRight:Radius.circular(30),
                 )
               ),
             child: Column(
               children: [

                 Column(
                   children: [
                     SizedBox(height: 20,),
                     Text(
                       date,
                       style: TextStyle(
                         fontSize: 16,
                         color: Colors.grey,
                     ),
                     )
                   ],
                 )

               ],
             ),
             )


            ],
          ),
        ),
      ),
    );
  }
}