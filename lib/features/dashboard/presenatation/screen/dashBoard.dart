import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/schedule_list.dart';

class DashBoardPage extends StatelessWidget {
  // final BusinessTypeSelectionController controller = Get.put(BusinessTypeSelectionController());
  final TextEditingController customTypeController = TextEditingController();
  String date = 'March 25, 2024';
  String day = 'Today';
  String? imageUrl;
  List<int?> postCounts = [1, 2, 5, 0, 3, 4, 2]; // one value per day
  List<String> weekdays = ["S", "M", "T", "W", "T", "F", "S"];
  List<int?> dates = [1, 2, 3, 4, 5, 6, 7]; // replace with actual dates
  int currentIndex = DateTime.now().weekday % 7; // 0 for Sunday
  int total = 0011;
  final List<Map<String, dynamic>> posts = [
    {
      "image": "assets/images/1.jpg",
      "profileImage": "assets/images/profile_image.png",
      "name": "Alice",
      "repostCount": 5,
      "likeCount": 120
    },
    {
      "image": "assets/images/2.jpg",
      "profileImage": "assets/images/profile_image.png",
      "name": "Bob",
      "repostCount": 2,
      "likeCount": 800
    },
    {
      "image": "assets/images/3.jpg",
      "profileImage": "assets/images/profile_image.png",
      "name": "Charlie",
      "repostCount": 700,
      "likeCount": 20
    },
  ];



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
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 00),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              // Header section
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
                 SizedBox(height: 20,),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           SizedBox(height: 20,),
                           Text(
                             date,
                             style: TextStyle(
                               fontSize: 16,
                               color: Colors.grey,
                           ),
                           ),
                           SizedBox(height: 5,),
                           Text(
                             day,
                             style: TextStyle(
                               fontSize: 20,
                               color: Colors.black,
                                 fontWeight: FontWeight.bold
                             ),
                           ),
                         ],
                       ),

                       Container(
                         width: 50,
                         height: 50,
                         decoration: const BoxDecoration(
                           shape: BoxShape.circle, // Round shape
                           color: Colors.grey, // Background color (optional)
                         ),
                         child: imageUrl == null || imageUrl!.isEmpty
                             ? const Icon(
                           Icons.person,
                           size: 40,
                           color: Colors.white,
                         )
                             : ClipOval(
                           child: Image.network(
                             imageUrl!,
                             fit: BoxFit.cover,
                             width: 70,
                             height: 70,
                           ),
                         ),
                       )


                     ],
                   ),
                 ),
                 SizedBox(height: 20,),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: List.generate(7, (index) {
                     bool isToday = index == currentIndex;

                     int? postCount = postCounts[index]; // ✅ FIXED

                     return GestureDetector(
                       onTap: () {
                         // handle tap
                       },
                       child: Container(
                         margin: const EdgeInsets.symmetric(horizontal: 10),
                         child: Column(
                           children: [
                             Text(
                               weekdays[index],
                               style: TextStyle(
                                 color: isToday ? Colors.black : Colors.grey,
                                 fontSize: 12,
                                 fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                               ),
                             ),
                             Text(
                               dates[index].toString(),
                               style: TextStyle(
                                 color: isToday ? Colors.black : Colors.grey,
                                 fontSize: 16,
                                 fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                               ),
                             ),
                             const SizedBox(height: 4),

                             // Dots
                             SizedBox(
                               height: 16,
                               child: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: List.generate(
                                   (postCount ?? 0) > 3 ? 3 : (postCount ?? 0),
                                       (dotIndex) {
                                     Color circleColor;
                                     if ((postCount ?? 0) > 3 && dotIndex == 2) {
                                       circleColor = Colors.black;
                                     } else {
                                       switch (dotIndex) {
                                         case 0:
                                           circleColor = Colors.blue;
                                           break;
                                         case 1:
                                           circleColor = Colors.grey;
                                           break;
                                         case 2:
                                           circleColor = Colors.pink;
                                           break;
                                         default:
                                           circleColor = Colors.grey;
                                       }
                                     }
                                     return Container(
                                       margin: const EdgeInsets.only(right: 4),
                                       width: 8,
                                       height: 8,
                                       decoration: BoxDecoration(
                                         shape: BoxShape.circle,
                                         color: circleColor,
                                       ),
                                     );
                                   },
                                 ),
                               ),
                             )
                           ],
                         ),
                       ),
                     );
                   }),
                 ),
                 SizedBox(height: 20,),

               ],
             ),
             ),

              SizedBox(height: 15,),

              // Dashboard Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2 - 15,
                      padding: const EdgeInsets.all(12), // for spacing inside container
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // space texts
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "Post \nPublished",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            total.toString(),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                    Container(
                      width: MediaQuery.of(context).size.width / 2 - 15,
                      padding: const EdgeInsets.all(12), // for spacing inside container
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // space texts
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            total.toString(),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Reels \nPublished",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2 - 15,
                      padding: const EdgeInsets.all(12), // for spacing inside container
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // space texts
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "Story \nCreated",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            total.toString(),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                    Container(
                      width: MediaQuery.of(context).size.width / 2 - 15,
                      padding: const EdgeInsets.all(12), // for spacing inside container
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // space texts
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            total.toString(),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Weekly \nViews",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Container(
                  // width: MediaQuery.of(context).size.width / 2 - 15,
                  padding: const EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10), // for spacing inside container
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // space texts
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          "Average Engagement",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        total.toString() + "%",
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Create and Calender
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 1.7 - 10,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007CFE),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_box_rounded, color: Colors.white, size: 15),
                          SizedBox(width: 5),
                          Text(
                            "Create Weekly Content",
                            style: TextStyle(color: Colors.white, fontSize: 12 ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SchedulePage(),
                          ),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3 - 10,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF277F),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.calendar_month , color: Colors.white, size: 15),
                            SizedBox(width: 5),
                            Text(
                              "Calendar",
                              style: TextStyle(color: Colors.white, fontSize: 12 ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //Most Recent Post
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Text(
                        'Most Recent',
                        style: const TextStyle(
                          color: Color(0xFF6D6D73),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("=========== Most recent Post");
                      },
                      child: Row(
                        children: const [
                          Text(
                            "See All",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.blue,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: 200, // <-- Give a fixed height
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: posts.map((post) {
                        return Container(
                          width: MediaQuery.of(context).size.width / 2.5 - 15,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: AssetImage(post['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Top-left profile + name
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius:  BorderRadius.circular(25)
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: AssetImage(post['profileImage']),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        post['name'],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.fade
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Bottom row with repost and likes
                              Positioned(
                                bottom: 05,
                                left: 05,
                                right: 05,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 30.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius:  BorderRadius.circular(25)
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.repeat, color: Colors.white, size: 15),
                                            const SizedBox(width: 4),
                                            Text(
                                              post['repostCount'].toString(),
                                              overflow: TextOverflow.fade,
                                              style: const TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '|',
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                        const SizedBox(width: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.favorite, color: Colors.white, size: 15),
                                            const SizedBox(width: 4),
                                            Text(
                                              post['likeCount'].toString(),
                                              overflow: TextOverflow.fade,
                                              style: const TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 15,),
              //edit photo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  clipBehavior: Clip.hardEdge, // ✅ Ensures the image respects the border radius
                  child: Image.asset(
                    "assets/images/edit_photo.png",
                    fit: BoxFit.cover, // ✅ Makes the image fill nicely
                  ),
                ),
              ),

              SizedBox(height: 15,),

              //For You Post
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Text(
                        'For you',
                        style: const TextStyle(
                          color: Color(0xFF6D6D73),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("=========== For you");
                      },
                      child: Row(
                        children: const [
                          Text(
                            "See All",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.blue,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: 200, // <-- Give a fixed height
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: posts.map((post) {
                        return Container(
                          width: MediaQuery.of(context).size.width / 2.5 - 15,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: AssetImage(post['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Top-left profile + name
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius:  BorderRadius.circular(25)
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: AssetImage(post['profileImage']),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        post['name'],
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.fade
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Bottom row with repost and likes
                              Positioned(
                                bottom: 05,
                                left: 05,
                                right: 05,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius:  BorderRadius.circular(25)
                                    ),
                                    child: Row(
                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.repeat, color: Colors.white, size: 15),
                                            const SizedBox(width: 4),
                                            Text(
                                              post['repostCount'].toString(),
                                              overflow: TextOverflow.fade,
                                              style: const TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '|',
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                        const SizedBox(width: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.favorite, color: Colors.white, size: 15),
                                            const SizedBox(width: 4),
                                            Text(
                                              post['likeCount'].toString(),
                                              overflow: TextOverflow.fade,
                                              style: const TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 35,),

            ],
          ),
        ),
      ),
    );
  }
}