import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class IncidentCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const IncidentCard({Key? key, required this.data}) : super(key: key);

  @override
  _IncidentCardState createState() => _IncidentCardState();
}

class _IncidentCardState extends State<IncidentCard> {
  bool isExpanded = false;

  // ฟังก์ชันสำหรับแปลง severity จาก int เป็นข้อความ
  String _mapSeverity(dynamic value) {
    // ควรเป็น int หากมีข้อมูลถูกต้อง
    int severity = int.tryParse(value.toString()) ?? 0;
    switch (severity) {
      case 1:
        return "Low";
      case 2:
        return "Medium";
      case 3:
        return "High";
      case 4:
        return "Critical";
      default:
        return "Unknown";
    }
  }

  // ฟังก์ชันสำหรับแปลง status จาก int เป็นข้อความ
  String _mapStatus(dynamic value) {
    int status = int.tryParse(value.toString()) ?? 0;
    switch (status) {
      case 1:
        return "Open";
      case 2:
        return "Closed";
      default:
        return "Unknown";
    }
  }

  // ฟังก์ชันสำหรับแปลง action จาก int เป็นข้อความ
  String _mapAction(dynamic value) {
    int action = int.tryParse(value.toString()) ?? 0;
    switch (action) {
      case 1:
        return "Blocked";
      case 2:
        return "Detected";
      default:
        return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูล id และ name จาก data และแปลงเป็น String
    final String incidentId = (widget.data['id'] ?? '').toString();
    final String incidentName = (widget.data['name'] ?? 'N/A').toString();

    // แปลง Timestamp จาก field close เป็น DateTime
    final Timestamp? closeTS = widget.data['close'] as Timestamp?;
    final DateTime incidentDate = closeTS?.toDate() ?? DateTime(1970, 1, 1);
    final String formattedCloseDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(incidentDate);

    // ดึงและแปลงค่า severity, status และ action จาก Firestore
    final severity = _mapSeverity(widget.data['severity'] ?? '');
    final status = _mapStatus(widget.data['status'] ?? '');
    final action = _mapAction(widget.data['action'] ?? '');

    // ดึงข้อมูล created (create) จาก Firebase ซึ่งเป็น Timestamp
    final Timestamp? createTS = widget.data['create'] as Timestamp?;
    final DateTime createdDate = createTS?.toDate() ?? DateTime(1970, 1, 1);
    final String formattedCreatedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(createdDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            ListTile(
              leading: IconButton(
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[700],
                ),
                onPressed: () => setState(() => isExpanded = !isExpanded),
              ),
              // เมื่อไม่ขยาย ให้แสดง id กับ name อยู่ในบรรทัดเดียวกัน
              title: isExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ID: $incidentId",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("Name: $incidentName",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Text(
                      "ID: $incidentId  Endpoint Name: $incidentName",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Severity: $severity"),
                      Text("Status: $status"),
                      Text("Action: $action"),
                      Text("Created: $formattedCreatedDate"),
                      Text("Close: $formattedCloseDate"),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
