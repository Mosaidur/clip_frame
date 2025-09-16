import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AboutMeWidget extends StatelessWidget {
  const AboutMeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x33F4DEC0),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          _infoRow("Membership", "Premium", valueColor: Color(0xFFFF277F)),
          _infoRow("Business Name", "Lorem Business"),
          _infoRow("Description", "About some things"),
          _dropdownRow("Business Category", "Restaurant"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Platforms",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Row(
                children: [
                  Image.asset("assets/images/facebook.png", height: 20),
                  const SizedBox(width: 8),
                  Image.asset("assets/images/instagram.png", height: 20),
                  const SizedBox(width: 8),
                  Image.asset("assets/images/tiktok.png", height: 20),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          _dropdownRow("Preferred Language", "English"),
          _dropdownRow("Timezone", "GMT"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Password",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              GestureDetector(
                onTap: () {},
                child: const Text("Change Password",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF007CFE))),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "LOG OUT",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF277F)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value, {Color valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor)),
        ],
      ),
    );
  }

  Widget _dropdownRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            items: [value].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
            onChanged: (val) {},
          )
        ],
      ),
    );
  }
}