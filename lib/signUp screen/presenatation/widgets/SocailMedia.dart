import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/BusinessTypeSelectionController.dart';

class ScoicalMediaPage extends StatelessWidget {
  final TextEditingController customTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              "Social Media Platforms Selection",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Choose one or more social media platforms",
              style: TextStyle(fontSize: 20, color: Colors.black54),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: const Text("Content Languages", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  // const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          // width: double.infinity,
                          height: 50,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Image.asset("assets/images/facebook.png") ,
                        ),

                        const SizedBox(width: 10,),
                        Container(
                          // width: double.infinity,
                          height: 50,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Image.asset("assets/images/instagram.png") ,
                        ),

                        const SizedBox(width: 10,),

                        Container(
                          // width: double.infinity,
                          height: 50,
                          width: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Image.asset("assets/images/tiktok.png") ,
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 10,),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}