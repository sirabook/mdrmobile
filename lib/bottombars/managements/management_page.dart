import 'package:flutter/material.dart';
import 'package:mdr_mobile/bottombars/managements/tenants/tenant_page..dart';


// สมมุติว่า DashboardPage และ EndpointPage ถูกสร้างไว้แล้ว

class ManagementPage extends StatelessWidget {
  final int subPageIndex; // 0: Dashboard, 1: Endpoint

  const ManagementPage({Key? key, required this.subPageIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // เลือกแสดงหน้าตาม subPageIndex
    switch (subPageIndex) {
      case 0:
        return TenantPage();
      // case 1:
      //   return IncidentPage();
      default:
        return Container();
    }
  }
}
