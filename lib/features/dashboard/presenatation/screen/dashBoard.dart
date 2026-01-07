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
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  day,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildProfileAvatar(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildWeeklyTimeline(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Dashboard Summary Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: "Post\nPublished",
                            value: total.toString(),
                            alignment: MainAxisAlignment.spaceBetween,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: "Reels\nPublished",
                            value: total.toString(),
                            alignment: MainAxisAlignment.spaceBetween,
                            reverse: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: "Story\nCreated",
                            value: total.toString(),
                            alignment: MainAxisAlignment.spaceBetween,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: "Weekly\nViews",
                            value: total.toString(),
                            alignment: MainAxisAlignment.spaceBetween,
                            reverse: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SummaryCard(
                      label: "Average Engagement",
                      value: "$total%",
                      alignment: MainAxisAlignment.spaceBetween,
                      fullWidth: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Content Create and Calender
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _ActionButton(
                        icon: Icons.add_box_rounded,
                        label: "Create Weekly Content",
                        color: const Color(0xFF007CFE),
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: _ActionButton(
                        icon: Icons.calendar_month,
                        label: "Calendar",
                        color: const Color(0xFFFF277F),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SchedulePage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Most Recent Section
              _SectionHeader(title: "Most Recent", onSeeAll: () {}),
              _buildPostList(context),

              const SizedBox(height: 20),

              // Edit Photo Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/edit_photo.png",
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // For You Section
              _SectionHeader(title: "For You", onSeeAll: () {}),
              _buildPostList(context),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.5),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? const Icon(Icons.person, size: 30, color: Colors.black54)
          : ClipOval(
        child: Image.network(imageUrl!, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildWeeklyTimeline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          bool isToday = index == currentIndex;
          int postCount = postCounts[index] ?? 0;

          return Expanded(
            child: Column(
              children: [
                Text(
                  weekdays[index],
                  style: TextStyle(
                    color: isToday ? Colors.black : Colors.black38,
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  dates[index].toString(),
                  style: TextStyle(
                    color: isToday ? Colors.black : Colors.black38,
                    fontSize: 16,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                _buildDots(postCount),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDots(int count) {
    int displayCount = count > 3 ? 3 : count;
    return SizedBox(
      height: 8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(displayCount, (i) {
          Color dotColor = Colors.grey;
          if (count > 3 && i == 2) {
            dotColor = Colors.black;
          } else {
            dotColor = [Colors.blue, Colors.grey, Colors.pink][i % 3];
          }
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          );
        }),
      ),
    );
  }

  Widget _buildPostList(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _PostCard(post: post);
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final MainAxisAlignment alignment;
  final bool reverse;
  final bool fullWidth;

  const _SummaryCard({
    required this.label,
    required this.value,
    this.alignment = MainAxisAlignment.start,
    this.reverse = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: alignment,
        children: reverse
            ? [
          _valueText(),
          const SizedBox(width: 8),
          Expanded(child: _labelText()),
        ]
            : [
          Expanded(child: _labelText()),
          const SizedBox(width: 8),
          _valueText(),
        ],
      ),
    );
  }

  Widget _labelText() {
    return Text(
      label,
      style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.2),
    );
  }

  Widget _valueText() {
    return Text(
      value,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: const [
                Text("See All", style: TextStyle(color: Colors.blue, fontSize: 12)),
                Icon(Icons.chevron_right, color: Colors.blue, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(post['image']),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            child: _buildProfileTag(),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: _buildStatsTag(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundImage: AssetImage(post['profileImage']),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              post['name'],
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(icon: Icons.repeat, count: post['repostCount'].toString()),
          const Text("|", style: TextStyle(color: Colors.white24, fontSize: 10)),
          _StatItem(icon: Icons.favorite, count: post['likeCount'].toString()),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String count;

  const _StatItem({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 12),
        const SizedBox(width: 2),
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }
}