import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentSeverity extends StatefulWidget {
  final int? selectedDays;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;

  const IncidentSeverity({
    Key? key,
    this.selectedDays,
    this.selectedStartDate,
    this.selectedEndDate,
  }) : super(key: key);

  @override
  _IncidentSeverityState createState() => _IncidentSeverityState();
}

class _IncidentSeverityState extends State<IncidentSeverity> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // count: index 0 = Low, 1 = Medium, 2 = High, 3 = Critical
  List<double> count = [0, 0, 0, 0];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchIncidentSeverityData();
  }

  @override
  void didUpdateWidget(covariant IncidentSeverity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDays != widget.selectedDays ||
        oldWidget.selectedStartDate != widget.selectedStartDate ||
        oldWidget.selectedEndDate != widget.selectedEndDate) {
      fetchIncidentSeverityData();
    }
  }

  Future<void> fetchIncidentSeverityData() async {
    setState(() {
      isLoading = true;
    });

    try {
      DateTime startDate;
      DateTime endDate = DateTime.now();

      if (widget.selectedStartDate != null && widget.selectedEndDate != null) {
        startDate = widget.selectedStartDate!;
        endDate = widget.selectedEndDate!;
      } else if (widget.selectedDays != null) {
        startDate = DateTime.now().subtract(Duration(days: widget.selectedDays!));
      } else {
        return;
      }

      QuerySnapshot snapshot = await _firestore
          .collection('generated')
          .where('close', isGreaterThanOrEqualTo: startDate)
          .where('close', isLessThanOrEqualTo: endDate)
          .get();

      // รีเซ็ต count สำหรับแต่ละกลุ่ม: [Low, Medium, High, Critical]
      List<double> totalIncident = [0, 0, 0, 0];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        // ดึงค่า severity ที่เป็น generated field (1 = Low, 2 = Medium, 3 = High, 4 = Critical)
        if (data["severity"] != null) {
          int severityValue = data["severity"];
          // นับจำนวนในแต่ละกลุ่ม
          if (severityValue == 1) {
            totalIncident[0]++;
          } else if (severityValue == 2) {
            totalIncident[1]++;
          } else if (severityValue == 3) {
            totalIncident[2]++;
          } else if (severityValue == 4) {
            totalIncident[3]++;
          }
        }
      }

      setState(() {
        count = totalIncident; // อัปเดตค่า count
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching incident summary: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Color getIncidentSeverityColor(String severity) {
    switch (severity) {
      case "Critical":
        return Colors.red;
      case "High":
        return Colors.orange;
      case "Medium":
        return Colors.lightBlueAccent.shade700;
      case "Low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // รายการ severityLevels แสดงผลตามลำดับ: Critical, High, Medium, Low
    List<String> severityLevels = ["Critical", "High", "Medium", "Low"];

    return SizedBox(
      height: 115,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: severityLevels.length,
              itemBuilder: (context, index) {
                String severity = severityLevels[index];

                return SizedBox(
                  width: MediaQuery.of(context).size.width / 3 - 8,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: getIncidentSeverityColor(severity),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          severity,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Severity",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          // count ถูกเก็บในลำดับ [Low, Medium, High, Critical] ดังนั้นเราจึงใช้ count[3-index]
                          "${count[3 - index].toInt()}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
