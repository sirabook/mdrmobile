import 'package:flutter/material.dart';
import 'package:mdr_mobile/bottombars/days_filter.dart';
import 'package:mdr_mobile/bottombars/incident/Incidents/incidents_list.dart';

class IncidentsPage extends StatefulWidget {
  const IncidentsPage({Key? key}) : super(key: key);

  @override
  _IncidentsPageState createState() => _IncidentsPageState();
}

class _IncidentsPageState extends State<IncidentsPage> {
  int? selectedDays = 1;
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
      color: const Color.fromARGB(255, 255, 240, 199),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DaysFilter(
                            selectedDays: selectedDays,
                            selectedStartDate: selectedStartDate,
                            selectedEndDate: selectedEndDate,
                            onFilterChanged: updateFilter,
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Incidents",
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(
                      height: constraints.maxHeight, // ป้องกัน Overflow
                      child: IncidentsList(
                        selectedDays: selectedDays,
                        selectedStartDate: selectedStartDate,
                        selectedEndDate: selectedEndDate,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
