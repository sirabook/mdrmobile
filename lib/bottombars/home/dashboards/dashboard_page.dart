import 'package:flutter/material.dart';
import 'package:mdr_mobile/bottombars/home/dashboards/alerted.dart';
import 'package:mdr_mobile/bottombars/home/dashboards/severity.dart';
import 'package:mdr_mobile/bottombars/days_filter.dart';
import 'package:mdr_mobile/bottombars/home/dashboards/summary.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int? selectedDays = 1; // ค่าเริ่มต้น: 1 วัน
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  void updateFilter(int? days, {DateTime? startDate, DateTime? endDate}) {
    setState(() {
      if (days != null) {
        selectedDays = days;
        selectedStartDate = null;
        selectedEndDate = null;
      } else if (startDate != null && endDate != null) {
        selectedDays = null;
        selectedStartDate = startDate;
        selectedEndDate = endDate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 255, 240, 199),
      child: ListView(      
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 ใช้ DaysFilter ที่รองรับช่วงวัน
                DaysFilter(
                  selectedDays: selectedDays,
                  selectedStartDate: selectedStartDate,
                  selectedEndDate: selectedEndDate,
                  onFilterChanged: updateFilter,
                ),
                const SizedBox(height: 20),

                // 🔹 Dashboard
                const Text(
                  "Dashboard",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                Severity(
                  selectedDays: selectedDays,
                  selectedStartDate: selectedStartDate,
                  selectedEndDate: selectedEndDate,
                ),

                SizedBox(height: 10),

                // 🔹 Summary Actions
                Summary(
                  selectedDays: selectedDays,
                  selectedStartDate: selectedStartDate,
                  selectedEndDate: selectedEndDate,
                ),
                

                // 🔹 Summary Actions
                Alerted(
                  selectedDays: selectedDays,
                  selectedStartDate: selectedStartDate,
                  selectedEndDate: selectedEndDate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
