import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mdr_mobile/test_api/home_page2.dart';

class LoginScreen2 extends StatefulWidget {
  @override
  _LoginScreen2State createState() => _LoginScreen2State();
}

class _LoginScreen2State extends State<LoginScreen2> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;

  Future<void> login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("กรุณากรอกชื่อผู้ใช้และรหัสผ่าน")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://csoc-center.com:8000/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      print("🔴 Response Code: ${response.statusCode}");
      print("🔴 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // บันทึกข้อมูล user ลง SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', data["_id"]);
        await prefs.setString('fullname', data["fullname"]);
        await prefs.setString('email', data["email"]);
        await prefs.setString('role', data["role"]);
        await prefs.setString('tel', data["tel"]);

        // ไปที่ HomeMainScreen พร้อมส่งข้อมูล user
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeMainScreen2(userData: data)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง")),
        );
      }
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด กรุณาลองใหม่")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ใช้ Stack เพื่อซ้อนเลเยอร์ของพื้นหลังและฟอร์ม
      body: Stack(
        children: [
          // พื้นหลังสีครีมด้านล่าง
          Container(
            color: Color(0xFFF8F5E5), // โทนครีมหรือปรับตามต้องการ
          ),
          // โค้งด้านบนสีเขียวเข้ม
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopCurveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                color: Color(0xFF114B5F), // ปรับเฉดสีเขียวเข้มตามต้องการ
              ),
            ),
          ),
          // สามารถเพิ่ม Decoration อื่น ๆ ได้ เช่น วงกลมหรือโค้งด้านล่างซ้าย/ขวา
          // ตัวอย่างวงกลมด้านล่างซ้าย
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Color(0xFF66BB6A).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // วางฟอร์มล็อกอินตรงกลาง
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // โลโก้หรือข้อความด้านบน
                  Text(
                    "MDR CENTER",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 60),
                  // Card หรือ Container สำหรับฟอร์ม
                  Container(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Username
                        TextField(
  controller: usernameController,
  style: TextStyle(color: Colors.white), // กำหนดสีของตัวอักษร
  decoration: InputDecoration(
    labelText: "Username",
    labelStyle: TextStyle(color: Colors.white), // กำหนดสีของ label
    prefixIcon: Icon(Icons.person, color: Colors.white),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.white), // กำหนดสีของเส้นขอบเมื่อไม่ได้เลือก
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.blue), // กำหนดสีของเส้นขอบเมื่อเลือก
    ),
  ),
),

                        SizedBox(height: 20),
                        // Password
                        TextField(
  controller: passwordController,
  obscureText: !isPasswordVisible,
  style: TextStyle(color: Colors.white), // กำหนดสีตัวอักษร
  decoration: InputDecoration(
    labelText: "Password",
    labelStyle: TextStyle(color: Colors.white), // กำหนดสีของ label
    prefixIcon: Icon(Icons.lock, color: Colors.white),
    suffixIcon: IconButton(
      icon: Icon(
        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
        color: Colors.white,
      ),
      onPressed: () {
        setState(() {
          isPasswordVisible = !isPasswordVisible;
        });
      },
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.white), // สีของเส้นขอบปกติ
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.blue), // สีของเส้นขอบเมื่อกดเลือก
    ),
  ),
),

                        // ลิงก์ Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // เขียนโค้ด Forgot Password ได้ตามต้องการ
                            },
                            child: Text("Forgot Password?",style: TextStyle(color: Colors.yellow),),
                          ),
                        ),
                        SizedBox(height: 20),
                        // ปุ่ม Sign in
                        ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            iconColor: Color(0xFF114B5F), // สีปุ่มเขียวเข้ม
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Sign in",
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// คลาสสำหรับสร้างโค้งด้านบน
class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // สร้าง path ให้โค้งแบบง่าย ๆ
    Path path = Path();
    path.lineTo(0, size.height - 60);
    // โค้งจากจุด (0, height-60) ไป (width, height-60) โดยใช้ control point กลาง
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
