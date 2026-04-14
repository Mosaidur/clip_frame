# Scheduling System Improvement Plan

এই ডকুমেন্টটি ClipFrame-এর scheduling system-কে আরও উন্নত করার জন্য গৃহীত পদক্ষেপগুলো বর্ণনা করে।

## ১. গৃহীত পরিবর্তনসমূহ (Implemented Changes)

### ক. Local Notifications (Offline Reminders)
- **প্যাকেজ:** `flutter_local_notifications`, `timezone`
- **বিবরণ:** ইন্টারনেট না থাকলেও যাতে ইউজার সঠিক সময়ে নোটিফিকেশন পায়, সেজন্য লোকাল নোটিফিকেশন সার্ভিস ইমপ্লিমেন্ট করা হয়েছে। 
- **কিভাবে কাজ করে:** যখনই সার্ভার থেকে শিডিউলড পোস্টগুলো ফেচ করা হয়, তখন সেগুলো অটোমেটিক্যালি ডিভাইসের অ্যালার্ম সিস্টেমে রেজিস্টার হয়ে যায়।

### খ. Local Caching (Sqflite)
- **প্যাকেজ:** `sqflite`
- **বিবরণ:** অফলাইনে ডাটা দেখানোর জন্য লোকাল ডাটাবেস ব্যবহার করা হয়েছে। 
- **সুবিধা:** ইউজার ইন্টারনেট ছাড়াও তার শিডিউল লিস্ট দেখতে পারবে এবং অ্যাপ খোলার সাথে সাথে ডাটা লোড হবে (API কলের অপেক্ষা করতে হবে না)।

### গ. Background Sync (WorkManager)
- **প্যাকেজ:** `workmanager`
- **বিবরণ:** প্রতি ১ ঘণ্টা অন্তর ব্যাকগ্রাউন্ডে ডাটা সিঙ্ক করার জন্য মেকানিজম সেটআপ করা হয়েছে। এটি ডাটা আপ-টু-ডেট রাখতে সাহায্য করে।

### ঘ. UI Feedback (Last Synced)
- **বিবরণ:** ইউজারকে জানানো হয় শেষ কবে ডাটা সিঙ্ক হয়েছে। এটি ইউজারের মনে বিশ্বাসযোগ্যতা তৈরি করে।

## ২. টেকনিক্যাল ডিটেইলস (Technical Details)

### নতুন ফাইলসমূহ:
1. `lib/core/services/notification_service.dart`: নোটিফিকেশন হ্যান্ডেল করার জন্য।
2. `lib/core/services/database_service.dart`: লোকাল ক্যাশিং হ্যান্ডেল করার জন্য।

### পরিবর্তিত ফাইলসমূহ:
1. `lib/main.dart`: সার্ভিসগুলো ইনিশিয়ালাইজ করার জন্য।
2. `lib/features/schedule/presenatation/controller/schedule_controller.dart`: ক্যাশ এবং নোটিফিকেশন সিঙ্ক লজিক যুক্ত করার জন্য।
3. `lib/features/schedule/presenatation/screen/schedule.dart`: "Last Synced" ইউআই দেখানোর জন্য।

## ৩. ভবিষ্যৎ পরিকল্পনা (Future Enhancements)

- **WebSocket/FCM integration:** পোলিং (polling) পুরোপুরি বন্ধ করে পুশ নোটিফিকেশনের মাধ্যমে ডাটা আপডেট করা।
- **Retry Mechanism:** ব্যাকগ্রাউন্ডে ফেইলড আপলোডগুলো অটোমেটিক্যালি পুনরায় চেষ্টা করা।
- **Analytics Offline:** অফলাইনে ইউজার অ্যাকশন ট্র্যাক করে অনলাইনে আসার পর সার্ভারে পাঠানো।

---
**Date:** 2026-04-14  
**Status:** Implemented (Phase 1)
