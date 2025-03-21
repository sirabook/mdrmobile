import 'package:flutter/material.dart';
import 'package:mdr_mobile/test_api/login_screen2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeMainScreen2 extends StatelessWidget {
  final Map<String, dynamic> userData; // รับข้อมูลผู้ใช้

  HomeMainScreen2({required this.userData});

  // ฟังก์ชันออกจากระบบ
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ลบข้อมูลทั้งหมดออกจาก SharedPreferences

    // กลับไปที่หน้า Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // กำหนดสีพื้นหลังแบบ gradient
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.shade200, Colors.blueGrey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar แบบ custom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      "Home",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.logout, color: Colors.white, size: 28),
                      onPressed: () => logout(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow("👤 ชื่อ", userData['fullname']),
                            SizedBox(height: 12),
                            _buildInfoRow("📧 อีเมล", userData['email']),
                            SizedBox(height: 12),
                            _buildInfoRow("📞 โทรศัพท์", userData['tel']),
                            SizedBox(height: 12),
                            _buildInfoRow("🛠 ตำแหน่ง", userData['role']),
                            SizedBox(height: 30),
                            
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้าง Row สำหรับแสดงข้อมูลแต่ละรายการ
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
