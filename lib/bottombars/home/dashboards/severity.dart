import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Severity extends StatefulWidget {
  final int? selectedDays;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;

  const Severity({
    Key? key,
    this.selectedDays,
    this.selectedStartDate,
    this.selectedEndDate,
  }) : super(key: key);

  @override
  _SeverityState createState() => _SeverityState();
}

class _SeverityState extends State<Severity> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// โครงสร้างข้อมูลที่จะเก็บยอดรวม (count, blocked, detected) และรายการเอกสาร (blockedDocs, detectedDocs)
  Map<String, Map<String, dynamic>> severityData = {
    "Critical": {
      "count": 0,
      "blocked": 0,
      "detected": 0,
      "blockedDocs": <Map<String, dynamic>>[],
      "detectedDocs": <Map<String, dynamic>>[],
    },
    "High": {
      "count": 0,
      "blocked": 0,
      "detected": 0,
      "blockedDocs": <Map<String, dynamic>>[],
      "detectedDocs": <Map<String, dynamic>>[],
    },
    "Medium": {
      "count": 0,
      "blocked": 0,
      "detected": 0,
      "blockedDocs": <Map<String, dynamic>>[],
      "detectedDocs": <Map<String, dynamic>>[],
    },
    "Low": {
      "count": 0,
      "blocked": 0,
      "detected": 0,
      "blockedDocs": <Map<String, dynamic>>[],
      "detectedDocs": <Map<String, dynamic>>[],
    },
  };

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSeverityData();
  }

  @override
  void didUpdateWidget(covariant Severity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDays != widget.selectedDays ||
        oldWidget.selectedStartDate != widget.selectedStartDate ||
        oldWidget.selectedEndDate != widget.selectedEndDate) {
      fetchSeverityData();
    }
  }

  Future<void> fetchSeverityData() async {
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
        // ถ้าไม่มีการเลือกวันหรือช่วงเวลา ไม่ทำอะไร
        setState(() {
          isLoading = false;
        });
        return;
      }

      // เคลียร์ค่าเก่าก่อน (เผื่อผู้ใช้กดเปลี่ยนช่วงเวลา)
      severityData.forEach((key, value) {
        value["count"] = 0;
        value["blocked"] = 0;
        value["detected"] = 0;
        value["blockedDocs"] = <Map<String, dynamic>>[];
        value["detectedDocs"] = <Map<String, dynamic>>[];
      });

      // ดึงข้อมูลจาก collection 'generated' โดยใช้ฟิลด์ 'close' เป็นช่วงเวลา
      QuerySnapshot snapshot = await _firestore
          .collection('generated')
          .where('close', isGreaterThanOrEqualTo: startDate)
          .where('close', isLessThanOrEqualTo: endDate)
          .get();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // ดึงค่า severity และ action ในรูปแบบตัวเลข
        int? severityValue = data["severity"];
        int? actionValue = data["action"];

        // ดึงค่า id และ name สมมติว่าฟิลด์ใน Firestore คือ "id" และ "name"
        // ถ้าเป็นฟิลด์ชื่ออื่น ๆ ให้แก้ไขตามจริง
        var docId = data["id"] ?? "";
        var docName = data["name"] ?? "";

        // ถ้าไม่มีข้อมูลที่จำเป็นให้ข้ามการประมวลผล
        if (severityValue == null || actionValue == null) continue;

        // แปลง severityValue -> Label (1=Low,2=Medium,3=High,4=Critical)
        String severityLabel;
        switch (severityValue) {
          case 1:
            severityLabel = "Low";
            break;
          case 2:
            severityLabel = "Medium";
            break;
          case 3:
            severityLabel = "High";
            break;
          case 4:
            severityLabel = "Critical";
            break;
          default:
            continue; // ข้ามกรณีที่ไม่ตรงกับ 1-4
        }

        if (!severityData.containsKey(severityLabel)) continue;

        // ถ้า actionValue == 1 => blocked, == 2 => detected
        if (actionValue == 1) {
          severityData[severityLabel]!["blocked"] += 1;
          severityData[severityLabel]!["blockedDocs"].add({
            "id": docId,
            "name": docName,
          });
        } else if (actionValue == 2) {
          severityData[severityLabel]!["detected"] += 1;
          severityData[severityLabel]!["detectedDocs"].add({
            "id": docId,
            "name": docName,
          });
        }

        // count = blocked + detected
        severityData[severityLabel]!["count"] =
            severityData[severityLabel]!["blocked"] +
            severityData[severityLabel]!["detected"];
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching generated data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Color getSeverityColor(String severity) {
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
    List<String> severityLevels = ["Critical", "High", "Medium", "Low"];

    return SizedBox(
      height: 200,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: severityLevels.length,
              itemBuilder: (context, index) {
                String severity = severityLevels[index];
                var item = severityData[severity] ?? {
                  "count": 0,
                  "blocked": 0,
                  "detected": 0,
                  "blockedDocs": <Map<String, dynamic>>[],
                  "detectedDocs": <Map<String, dynamic>>[],
                };

                return SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 16,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: getSeverityColor(severity),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ส่วนหัว (ชื่อ Severity และ count)
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "$severity Severity",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${item["count"]}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ปุ่ม (หรือพื้นที่) สำหรับ "Blocked"
                        _buildInfoBox(
                          context,
                          label: "Blocked",
                          value: item["blocked"],
                          docList: item["blockedDocs"] ?? [],
                          severity: severity,
                        ),
                        const SizedBox(height: 5),
                        // ปุ่ม (หรือพื้นที่) สำหรับ "Detected"
                        _buildInfoBox(
                          context,
                          label: "Detected",
                          value: item["detected"],
                          docList: item["detectedDocs"] ?? [],
                          severity: severity,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// ฟังก์ชันสร้าง Box สำหรับแสดง Blocked/Detected พร้อม onTap
  Widget _buildInfoBox(
    BuildContext context, {
    required String label,
    required int value,
    required List<Map<String, dynamic>> docList,
    required String severity,
  }) {
    return InkWell(
      onTap: () {
        // ถ้ามีจำนวน > 0 จึงจะเปิด dialog แสดงรายการ
        if (value > 0) {
          _showDocsDialog(context, severity, label, docList);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "$label : $value",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  /// ฟังก์ชันสำหรับแสดง Bottom Sheet ที่แสดงรายการ ID และ Name
  void _showDocsDialog(
    BuildContext context,
    String severity,
    String label,
    List<Map<String, dynamic>> docList,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ด้านบนสุดแสดงเส้น indicator และปุ่มปิด
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // สามารถเพิ่ม indicator ด้านบนกลางได้ตามต้องการ
                    const SizedBox(width: 24), // Placeholder
                    Text(
                      "$severity Severity",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                // แสดง Action ที่เลือก
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Action : $label",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // ส่วนหัวตาราง (แสดงคอลัมน์ # และ name)
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "#",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          "name",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                // รายการข้อมูล (Scrollable)
                Expanded(
                  child: ListView.builder(
                    itemCount: docList.length,
                    itemBuilder: (context, index) {
                      final docData = docList[index];
                      final docId = docData["id"]?.toString() ?? "";
                      final docName = docData["name"]?.toString() ?? "";
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(docId),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(docName),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
