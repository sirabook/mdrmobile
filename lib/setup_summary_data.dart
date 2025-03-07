// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // ✅ ให้ Flutter รอการ init Firebase ก่อน
//   await Firebase.initializeApp(); // ✅ เรียกใช้ Firebase
//   addSampleSeverityData(); // ✅ เรียกใช้งานฟังก์ชันเพิ่มข้อมูล

//   runApp(MyApp());
// }
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(title: Text("Firestore Setup")),
//         body: Center(child: Text("กำลังเพิ่มข้อมูลไปยัง Firestore...")),
//       ),
//     );
//   }
// }
// void setupSummaryData() async {
//   FirebaseFirestore.instance.collection('dashboard').doc('summary').set({
//     "blocked": 60,
//     "detected": 489,
//   }).then((_) {
//     print("🔥 ข้อมูลถูกเพิ่มใน Firestore แล้ว!");
//   }).catchError((error) {
//     print("❌ เกิดข้อผิดพลาด: $error");
//   });
// }


// Future<void> addSampleSeverityData() async {
//   try {
//     List<Map<String, dynamic>> sampleData = [
//       {"severity": "Critical", "count": 30, "blocked": 15, "detected": 15},
//       {"severity": "Critical", "count": 25, "blocked": 10, "detected": 15},
//       {"severity": "High", "count": 40, "blocked": 20, "detected": 20},
//       {"severity": "High", "count": 35, "blocked": 18, "detected": 17},
//       {"severity": "Medium", "count": 50, "blocked": 25, "detected": 25},
//       {"severity": "Medium", "count": 45, "blocked": 22, "detected": 23},
//       {"severity": "Low", "count": 80, "blocked": 40, "detected": 40},
//       {"severity": "Low", "count": 100, "blocked": 50, "detected": 50},
//       {"severity": "Low", "count": 90, "blocked": 45, "detected": 45},
//       {"severity": "Critical", "count": 20, "blocked": 5, "detected": 15},
//     ];

//     for (var data in sampleData) {
//       await FirebaseFirestore.instance.collection('severity').add({
//         ...data,
//         "date": FieldValue.serverTimestamp(), // เพิ่ม timestamp ปัจจุบัน
//       });
//     }

//     print("✅ 10 Sample data added successfully!");
//   } catch (e) {
//     print("❌ Error adding sample data: $e");
//   }
// }

