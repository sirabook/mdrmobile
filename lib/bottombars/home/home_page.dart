import 'package:flutter/material.dart';
import 'package:mdr_mobile/bottombars/home/severity.dart';
import 'package:mdr_mobile/bottombars/home/days_filter.dart';
import 'package:mdr_mobile/bottombars/home/summary.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return SafeArea(
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

                const SizedBox(height: 20),

                // 🔹 Summary Actions
                Summary(
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
