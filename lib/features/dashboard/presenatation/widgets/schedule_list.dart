import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String selectedView = "Weekly";
  String selectedDate = "24"; // example selected date
  String? date ;
  String? day ;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    final result = getFormattedDate();
    date = result["date"]!;
    day = result["day"]!;
  }

  Map<String, String> getFormattedDate() {
    DateTime now = DateTime.now();

    // 📌 Format: March 25, 2024
    String date = DateFormat('MMMM d, y').format(now);

    // 📌 Format: Today / Tomorrow / Weekday
    String day;
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime tomorrow = today.add(const Duration(days: 1));

    if (now.difference(today).inDays == 0) {
      day = "Today";
    } else if (now.difference(tomorrow).inDays == 0) {
      day = "Tomorrow";
    } else {
      day = DateFormat('EEEE').format(now); // e.g. Friday
    }

    return {"date": date, "day": day};
  }


  final Map<String, dynamic> scheduleData = jsonDecode("""
  {
    "schedule": [
      {
        "time": "01:00",
        "posts": [
          {
            "title": "Lorem Ipsum title of the creation",
            "imageUrl": "https://i.pravatar.cc/150?img=10",
            "facebook": true,
            "instagram": true,
            "tiktok": false
          },
          {
            "title": "Another creation post",
            "imageUrl": "https://i.pravatar.cc/150?img=11",
            "facebook": false,
            "instagram": true,
            "tiktok": true
          }
        ]
      },
      {
        "time": "03:00",
        "posts": [
          {
            "title": "Sample post with only FB",
            "imageUrl": "https://i.pravatar.cc/150?img=12",
            "facebook": true,
            "instagram": false,
            "tiktok": false
          }
        ]
      },
      {
        "time": "05:50",
        "posts": [
          {
            "title": "Evening content for TikTok and Insta",
            "imageUrl": "https://i.pravatar.cc/150?img=13",
            "facebook": false,
            "instagram": true,
            "tiktok": true
          }
        ]
      }
    ]
  }
  """);

  // ✅ Weekday list (Sun → Sat, only first letters)
  final List<String> weekDays = ["S", "M", "T", "W", "T", "F", "S"];

  @override
  Widget build(BuildContext context) {
    List<dynamic> schedule = scheduleData["schedule"];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEBC894),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
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
                          date!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          day!,
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
              const SizedBox(height: 30),
              // Top header with view selector
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Calendar View",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedView =
                          selectedView == "Weekly" ? "Monthly" : "Weekly";
                        });
                      },
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Colors.purple),
                            const SizedBox(width: 6),
                            Text(selectedView,
                                style: const TextStyle(color: Colors.purple)),
                            const Icon(Icons.arrow_drop_down, color: Colors.purple),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          
              // Date row (Sun → Sat)
              Container(
                color: Colors.white,
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    itemBuilder: (_, i) {
                      String date = (21 + i).toString();
                      bool isSelected = selectedDate == date;
                      return GestureDetector(
                        onTap: () => setState(() => selectedDate = date),
                        child: Container(
                          width: 60,
                          // margin: const EdgeInsets.all(8),
                          // padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? Color(0xFF007CFE) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            // border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ✅ First letter of weekday
                              Text(
                                weekDays[i],
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color:
                                    isSelected ? Colors.white : Colors.black),
                              ),
                              Text(date,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                      isSelected ? Colors.white : Colors.black)
                              ),

                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Container(
                height: 10,
                color: Colors.white,
              ),
          
              // Timeline
              Expanded(
                child: ListView.builder(
                  itemCount: 24,
                  itemBuilder: (_, hour) {
                    String timeLabel = "${hour.toString().padLeft(2, '0')}:00"; // 00:00 → 23:00
                    // ✅ Match items by hour (ignores minutes)
                    var postData = schedule.firstWhere(
                          (item) {
                        final parts = (item["time"] as String).split(":");
                        final int itemHour = int.parse(parts[0]);
                        // group any 03:00 → 03:59 into "03:00"
                        return itemHour == hour;
                      },
                      orElse: () => {"time": timeLabel, "posts": []},
                    );
          
                    List<dynamic> posts = postData["posts"];
          
                    return Container(
                      color: Colors.white,
                      child: Stack(
                        children: [
                          // Divider in background (full width line)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                                height: 1,
                              ),
                            ),
                          ),

                          // Foreground row (time + posts)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Time label
                                Container(
                                  width: 70,
                                  color: Colors.purple.shade100,
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      timeLabel,
                                      style: const TextStyle(color: Colors.purple, fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                                // Posts section
                                Expanded(
                                  child: posts.isEmpty
                                      ? const SizedBox.shrink()
                                      : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children:
                                      posts.map((post) => _buildPostCard(post)).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(dynamic post) {
    return Container(
      width: 200,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Title row
      IntrinsicHeight(
      child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch, // ✅ stretch to same height
        children: [
          // Blue rectangle line
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: const Color(0xFF007CFE),
              borderRadius: BorderRadius.circular(25)
            ),
          ),
          const SizedBox(width: 6), // spacing between line & text

          // Title
          Expanded(
            child: Text(
              post["title"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 8),
          // Social icons
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // ✅ push icons to right
            children: [
              if (post["facebook"])
                const Icon(Icons.facebook, size: 18, color: Colors.blue),
              if (post["instagram"])
                const Icon(Icons.camera_alt, size: 18, color: Colors.purple),
              if (post["tiktok"])
                const Icon(Icons.music_note, size: 18, color: Colors.black),
            ],
          ),
          const SizedBox(height: 8),
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              post["imageUrl"],
              height: 60,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
