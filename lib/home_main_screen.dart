import 'package:flutter/material.dart';
import 'package:mdr_mobile/bottombars/home/home_page.dart';
import 'package:mdr_mobile/drawers/drawers.dart';
import 'package:mdr_mobile/appbars/app_bars.dart';
import 'package:mdr_mobile/bottombars/bottom_bars.dart'; // Import ไฟล์ใหม่

class HomeMainScreen extends StatelessWidget {
  final String userId;
  const HomeMainScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int notificationCount = 7;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    // const ApartmentPage(),
    // const DesktopPage(),
    // const NewsPage(),
  ];

  void _onNavItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBars(
        notificationCount: notificationCount,
        onNotificationTap: () {
          setState(() {
            if (notificationCount > 0) notificationCount--;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('คุณมี $notificationCount การแจ้งเตือน')),
          );
        },
        scaffoldKey: _scaffoldKey,
      ),
      drawer: const Drawers(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomBars(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavItemSelected,
      ),
    );
  }
}
