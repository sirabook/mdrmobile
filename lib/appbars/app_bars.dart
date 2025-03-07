import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:mdr_mobile/users/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBars extends StatelessWidget implements PreferredSizeWidget {
  final int notificationCount;
  final VoidCallback onNotificationTap;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AppBars({
    Key? key,
    required this.notificationCount,
    required this.onNotificationTap,
    required this.scaffoldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.purple, size: 40),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [
        _buildIconWithBorder(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications, color: Colors.white, size: 30),
              if (notificationCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: badges.Badge(
                    badgeContent: Text(
                      '$notificationCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    badgeStyle: const badges.BadgeStyle(badgeColor: Colors.red),
                  ),
                ),
            ],
          ),
          onTap: onNotificationTap,
        ),
        _buildIconWithBorder(
          icon: const Icon(Icons.account_circle, color: Colors.white, size: 30),
          onTap: () {
            showMenu(
              context: context,
              position: const RelativeRect.fromLTRB(1000, 80, 10, 0),
              items: [
                const PopupMenuItem(value: 1, child: Text('Profile')),
                const PopupMenuItem(value: 2, child: Text('Settings')),
                const PopupMenuItem(value: 3, child: Text('Logout')),
              ],
            ).then((value) async {
              if (value != null) {
                switch (value) {
                  case 1:
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile Clicked')));
                    break;
                  case 2:
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings Clicked')));
                    break;
                  case 3:
                  await FirebaseAuth.instance.signOut(); // ออกจากระบบ Firebase
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                     Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false, // Remove all previous routes
          );
                    break;
                }
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildIconWithBorder({required Widget icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.purple,
            border: Border.all(color: Colors.purple, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
