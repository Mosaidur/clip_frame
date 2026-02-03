import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clip_frame/core/services/api_services/schedule_service.dart';
import 'package:clip_frame/features/schedule/data/model.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String selectedView = "Weekly";
  String selectedDate = "24"; // example selected date
  String? date;
  String? day;
  String? imageUrl;
  List<SchedulePost> scheduledPosts = [];
  Map<int, List<SchedulePost>> postsByHour = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final result = getFormattedDate();
    date = result["date"]!;
    day = result["day"]!;
    _loadScheduledPosts();
  }

  Future<void> _loadScheduledPosts() async {
    final posts = await ScheduleService.fetchScheduledPosts();
    setState(() {
      scheduledPosts = posts;
      postsByHour = _groupPostsByHour(posts);
      isLoading = false;
    });
  }

  Map<int, List<SchedulePost>> _groupPostsByHour(List<SchedulePost> posts) {
    Map<int, List<SchedulePost>> grouped = {};

    for (var post in posts) {
      try {
        final dateTime = _extractDateFromRaw(post.rawScheduleTime);
        final hour = dateTime.hour;

        if (!grouped.containsKey(hour)) {
          grouped[hour] = [];
        }
        grouped[hour]!.add(post);
      } catch (e) {
        debugPrint("Error grouping post by hour: $e");
      }
    }

    return grouped;
  }

  DateTime _extractDateFromRaw(String rawTime) {
    if (rawTime.contains('date:') && rawTime.contains('time:')) {
      final datePart = rawTime.split('date:')[1].split(',')[0].trim();
      final timePart = rawTime.split('time:')[1].split('}')[0].trim();

      DateTime date = DateTime.parse(datePart);
      final timeSplit = timePart.split(':');
      int hour = int.parse(timeSplit[0]);
      int minute = int.parse(timeSplit[1]);

      return DateTime(date.year, date.month, date.day, hour, minute);
    }

    return DateTime.parse(rawTime);
  }

  Map<String, String> getFormattedDate() {
    DateTime now = DateTime.now();

    String date = DateFormat('MMMM d, y').format(now);

    String day;
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime tomorrow = today.add(const Duration(days: 1));

    if (now.difference(today).inDays == 0) {
      day = "Today";
    } else if (now.difference(tomorrow).inDays == 0) {
      day = "Tomorrow";
    } else {
      day = DateFormat('EEEE').format(now);
    }

    return {"date": date, "day": day};
  }

  // ✅ Weekday list (Sun → Sat, only first letters)
  final List<String> weekDays = ["S", "M", "T", "W", "T", "F", "S"];

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEBC894), Color(0xFFFFFFFF)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF007CFE)),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEBC894), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          date!,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        SizedBox(height: 5),
                        Text(
                          day!,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
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
                    ),
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
                    const Text(
                      "Calendar View",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedView = selectedView == "Weekly"
                              ? "Monthly"
                              : "Weekly";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              selectedView,
                              style: const TextStyle(color: Colors.purple),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.purple,
                            ),
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
                            color: isSelected
                                ? Color(0xFF007CFE)
                                : Colors.transparent,
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
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Container(height: 10, color: Colors.white),

              // Timeline
              Expanded(
                child: ListView.builder(
                  itemCount: 24,
                  itemBuilder: (_, hour) {
                    String timeLabel =
                        "${hour.toString().padLeft(2, '0')}:00"; // 00:00 → 23:00
                    List<SchedulePost> posts = postsByHour[hour] ?? [];

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
                                      style: const TextStyle(
                                        color: Colors.purple,
                                        fontSize: 12,
                                      ),
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
                                            children: posts
                                                .map(
                                                  (post) =>
                                                      _buildPostCard(post),
                                                )
                                                .toList(),
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

  Widget _buildPostCard(SchedulePost post) {
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
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // ✅ stretch to same height
              children: [
                // Blue rectangle line
                Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007CFE),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                const SizedBox(width: 6), // spacing between line & text
                // Title
                Expanded(
                  child: Text(
                    post.title,
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
          // Tags
          if (post.tags.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    post.tags.take(2).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: post.imageUrl.isNotEmpty
                ? Image.network(
                    post.thumbnailUrl ?? post.imageUrl,
                    height: 60,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  )
                : Container(
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
          ),
        ],
      ),
    );
  }
}
