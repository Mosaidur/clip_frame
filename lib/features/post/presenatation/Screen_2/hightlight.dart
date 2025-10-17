import 'package:flutter/cupertino.dart';

class Hightlight extends StatelessWidget {

  const Hightlight({super.key});

  @override
  Widget build(BuildContext context) {
    String title = "Video Highlight";
    String subTitle = "Create a reel showcasing your expert chefs cooking. This engages curiosity and shows the food quality naturally.";
    String url = "Video Highlight";
    String tips = "Why this idea? Trending #Food #Cooking content gets high engagement and saves on Instagram and TikTok. Idea product-first brands.";


    return Container(

        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ Color(0xFFEBC894), Color(0xFFFFFFFF), Color(0xFFB49EF4)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                  title,
                style: TextStyle(
                  fontFamily: "",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),

    );
  }
}
