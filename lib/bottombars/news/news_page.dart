import 'package:flutter/material.dart';
import 'package:mdr_mobile/bottombars/news/cybersecuritys/cybersecurity_page.dart';


class NewsPage extends StatelessWidget {
  final int subPageIndex; // 0: Dashboard, 1: Endpoint

  const NewsPage({Key? key, required this.subPageIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // เลือกแสดงหน้าตาม subPageIndex
    switch (subPageIndex) {
      case 0:
        return CybersecurityPage();
      case 1:
        return CybersecurityPage();
      default:
        return Container();
    }
  }
}
