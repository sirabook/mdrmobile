import 'package:flutter/material.dart';
import 'package:mdr_mobile/users/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> register() async {
    try {
      // สมัครสมาชิกด้วยอีเมลและรหัสผ่าน
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // บันทึกข้อมูลผู้ใช้ลง Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'userId': userCredential.user!.uid,
        'email': emailController.text,
        'username': userController.text,
        'address': addressController.text,
        'phone': phoneController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // แสดงข้อความสมัครสำเร็จ และนำไปหน้าล็อกอิน
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("สมัครสมาชิกสำเร็จ! กรุณาล็อกอิน")),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลัง
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/destopshop.png"), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                margin: EdgeInsets.only(top: 100),
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 5,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.food_bank,
                      size: 80,
                      color: Colors.deepPurple,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'สมัครสมาชิก',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'อีเมล',
                        hintText: 'ใส่อีเมลของคุณ',
                        prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: userController,
                      decoration: InputDecoration(
                        labelText: 'ชื่อผู้ใช้',
                        hintText: 'ใส่ชื่อผู้ใช้ของคุณ',
                        prefixIcon: Icon(Icons.person, color: Colors.deepPurple),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'รหัสผ่าน',
                        hintText: 'ใส่รหัสผ่านของคุณ',
                        prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'ที่อยู่',
                        hintText: 'ใส่ที่อยู่ของคุณ',
                        prefixIcon: Icon(Icons.location_on, color: Colors.deepPurple),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'เบอร์โทรศัพท์',
                        hintText: 'ใส่เบอร์โทรศัพท์ของคุณ',
                        prefixIcon: Icon(Icons.phone, color: Colors.deepPurple),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        iconColor: Colors.deepPurple,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'สมัครสมาชิก',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 20),
                    // ปุ่มกลับไปที่หน้าล็อกอิน
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // กลับไปที่หน้าล็อกอิน
                      },
                      child: Text('มีบัญชีแล้ว? เข้าสู่ระบบ'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
