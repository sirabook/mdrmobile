import 'package:flutter/material.dart';
import 'package:mdr_mobile/bottombars/home/dashboards/dashboard_page.dart';
import 'package:mdr_mobile/bottombars/home/endpoints/endpoint_page.dart';

// สมมุติว่า DashboardPage และ EndpointPage ถูกสร้างไว้แล้ว

class HomePage extends StatelessWidget {
  final int subPageIndex; // 0: Dashboard, 1: Endpoint

  const HomePage({Key? key, required this.subPageIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // เลือกแสดงหน้าตาม subPageIndex
    switch (subPageIndex) {
      case 0:
        return DashboardPage();
      case 1:
        return EndpointPage();
      default:
        return Container();
    }
  }
}
