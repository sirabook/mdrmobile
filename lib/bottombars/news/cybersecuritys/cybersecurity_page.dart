import 'package:flutter/material.dart';
import 'news_highlight.dart';
import 'news_list.dart';

class CybersecurityPage extends StatefulWidget {
  const CybersecurityPage({Key? key}) : super(key: key);
  @override
  _CybersecurityPageState createState() => _CybersecurityPageState();
}

class _CybersecurityPageState extends State<CybersecurityPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CyberSecurityCybersecurityPage(),
    );
  }
}

class CyberSecurityCybersecurityPage extends StatefulWidget {
  @override
  _CyberSecurityCybersecurityPageState createState() => _CyberSecurityCybersecurityPageState();
}

class _CyberSecurityCybersecurityPageState extends State<CyberSecurityCybersecurityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 240, 199),
          ),
          child: Column(
            children: [
              NewsHighlight(), // ✅ ส่วนของข่าวเด่น
              Text(
                "Cyber Security News",
                style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
              ),
              NewsList(), // ✅ รายการข่าว
            ],
          ),
        ),
      ),
    );
  }
}
