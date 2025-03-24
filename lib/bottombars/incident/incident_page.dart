import 'package:flutter/material.dart';
import 'package:mdr_mobile/bottombars/incident/Incidents/incidents_page.dart';


// สมมุติว่า DashboardPage และ EndpointPage ถูกสร้างไว้แล้ว

class IncidentPage extends StatelessWidget {
  final int subPageIndex; // 0: Dashboard, 1: Endpoint

  const IncidentPage({Key? key, required this.subPageIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // เลือกแสดงหน้าตาม subPageIndex
    switch (subPageIndex) {
      case 0:
        return IncidentsPage();
      // case 1:
      //   return IncidentPage();
      default:
        return Container();
    }
  }
}
