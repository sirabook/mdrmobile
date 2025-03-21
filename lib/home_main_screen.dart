import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mdr_mobile/bottombars/incidents/incident_page.dart';
import 'package:mdr_mobile/bottombars/managements/management_page.dart';
import 'package:mdr_mobile/bottombars/home/home_page.dart';
import 'package:mdr_mobile/bottombars/news/news_page.dart';
import 'package:mdr_mobile/drawers/drawers.dart';
import 'package:mdr_mobile/appbars/app_bars.dart';
import 'package:mdr_mobile/bottombars/bottom_bars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeMainScreen extends StatelessWidget {
  final String userId;
  const HomeMainScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(userId: userId),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String userId;
  const MyHomePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int notificationCount = 0;
  int _selectedIndex = 0;
  int _homeSubPageIndex = 0; // 0: Dashboard, 1: Endpoint
  int _newsSubPageIndex = 1; // 0: Dashboard, 1: Endpoint

  // List สำหรับเก็บข้อความแจ้งเตือน
  List<String> notifications = [];

  // กำหนด key สำหรับแต่ละหน้า เพื่อใช้ในการรีเฟรชเฉพาะหน้า
  Key _homePageKey = UniqueKey();
  Key _managementPageKey = UniqueKey();
  Key _incidentPageKey = UniqueKey();
  Key _newsPageKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadNotifications();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        String title = message.notification!.title ?? "No Title";
        String body = message.notification!.body ?? "No Body";
        setState(() {
          notifications.add("$title: $body");
          notificationCount = notifications.length;
        });
        _saveNotifications();
      }
    });
  }

  // โหลด notifications จาก SharedPreferences
  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedNotifications = prefs.getStringList('notifications');
    if (storedNotifications != null) {
      setState(() {
        notifications = storedNotifications;
        notificationCount = notifications.length;
      });
    }
  }

  // บันทึก notifications ลง SharedPreferences
  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notifications', notifications);
  }

  // เคลียร์ notifications ใน SharedPreferences
  Future<void> _clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
  }

  // ฟังก์ชันสำหรับจัดการเมื่อมีการเลือกไอคอนใน BottomNavigationBar
  void _onNavItemSelected(int index) {
    if (_selectedIndex == index) {
      // ถ้ากดไอคอนเดียวกันกับที่กำลังแสดงอยู่ ให้รีเฟรชหน้าโดยเปลี่ยน key
      setState(() {
        switch (index) {
          case 0:
            _homePageKey = UniqueKey();
            break;
          case 1:
            _managementPageKey = UniqueKey();
            break;
          case 2:
            _incidentPageKey = UniqueKey();
            break;
          case 3:
            _newsPageKey = UniqueKey();
            break;
        }
      });
    } else {
      // ถ้าเลือกไอคอนที่ไม่ใช่หน้าปัจจุบัน ให้เปลี่ยนหน้าโดยไม่รีเฟรช
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // สร้างหน้าปัจจุบันโดยใช้ key ที่กำหนดไว้สำหรับแต่ละหน้า
  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return HomePage(key: _homePageKey, subPageIndex: _homeSubPageIndex);
      case 1:
        return ManagementPage(key: _managementPageKey);
      case 2:
        return IncidentPage(key: _incidentPageKey);
      case 3:
        return NewsPage(key: _newsPageKey, subPageIndex: _newsSubPageIndex);
      default:
        return Container();
    }
  }

  // ฟังก์ชันสำหรับจัดการเมื่อมีการเลือกเมนูจาก Drawer
  void _handleMenuItemTap(String item) {
    Navigator.pop(context); // ปิด Drawer
    // กรณีที่อยู่ในหน้า Home ให้เปลี่ยน subPageIndex
    if (_selectedIndex == 0) {
      if (item == "Dashboard") {
        setState(() {
          _homeSubPageIndex = 0;
        });
      } else if (item == "Endpoint") {
        setState(() {
          _homeSubPageIndex = 1;
        });
      }
    } else if (_selectedIndex == 1) {
      if (item == "Tenant") {
        print("Scroll to Tenant in ManagementPage");
      }
    } else if (_selectedIndex == 2) {
      if (item == "Incidents") {
        print("Scroll to Incident in Incidents");
      }
    } else if (_selectedIndex == 3) {
      if (item == "Threat Intelligence") {
        setState(() {
          _newsSubPageIndex = 0;
        });
      } else if (item == "Cyber Security") {
        setState(() {
          _newsSubPageIndex = 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // กำหนดค่า title และ menuItems ตามหน้า
    String title;
    List<String> menuItems;
    switch (_selectedIndex) {
      case 0:
        title = "Home";
        menuItems = ["Dashboard", "Endpoint"];
        break;
      case 1:
        title = "Management";
        menuItems = ["Tenant"];
        break;
      case 2:
        title = "Incident";
        menuItems = ["Incidents"];
        break;
      case 3:
        title = "News";
        menuItems = ["Threat Intelligence", "Cyber Security"];
        break;
      default:
        title = "Menu";
        menuItems = [];
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBars(
        notificationCount: notificationCount,
        onNotificationTap: _showNotificationsBottomSheet,
        scaffoldKey: _scaffoldKey,
        userId: widget.userId,
      ),
      drawer: Align(
        alignment: Alignment.topLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
          width: screenWidth / 2,
          child: Drawers(
            title: title,
            menuItems: menuItems,
            onItemSelected: _handleMenuItemTap,
          ),
        ),
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: BottomBars(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavItemSelected,
      ),
    );
  }

  // ฟังก์ชันแสดง Notifications ผ่าน BottomSheet
  void _showNotificationsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            children: [
              Text(
                "Notifications",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              if (notifications.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      "No new notifications",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.notifications, color: Colors.blue),
                        title: Text(notifications[index]),
                      );
                    },
                  ),
                ),
              TextButton(
                onPressed: () {
                  setState(() {
                    notifications.clear();
                    notificationCount = 0;
                  });
                  _clearNotifications();
                  Navigator.pop(context);
                },
                child: Text("Clear All", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }
}
