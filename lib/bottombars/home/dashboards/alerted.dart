import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Alerted extends StatefulWidget {
  final int? selectedDays;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;

  const Alerted({
    Key? key,
    this.selectedDays,
    this.selectedStartDate,
    this.selectedEndDate,
  }) : super(key: key);

  @override
  _AlertedState createState() => _AlertedState();
}

class _AlertedState extends State<Alerted> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// แต่ละ Map เก็บ key = "id|name" (หรือ doc.id ก็ได้)
  /// value = {'count': n, 'id': ..., 'name': ...}
  Map<String, Map<String, dynamic>> topAlertedPolicies = {};       // severity=4
  Map<String, Map<String, dynamic>> alertedServiceConnectors = {}; // severity=3,2
  Map<String, Map<String, dynamic>> topAlertedUser = {};           // severity=1

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAlertedData();
  }

  @override
  void didUpdateWidget(covariant Alerted oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDays != widget.selectedDays ||
        oldWidget.selectedStartDate != widget.selectedStartDate ||
        oldWidget.selectedEndDate != widget.selectedEndDate) {
      fetchAlertedData();
    }
  }

  Future<void> fetchAlertedData() async {
    setState(() {
      isLoading = true;
    });

    DateTime startDate;
    DateTime endDate = DateTime.now();

    if (widget.selectedStartDate != null && widget.selectedEndDate != null) {
      startDate = widget.selectedStartDate!;
      endDate = widget.selectedEndDate!;
    } else if (widget.selectedDays != null) {
      startDate = DateTime.now().subtract(Duration(days: widget.selectedDays!));
    } else {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // เคลียร์ค่าเก่า
    topAlertedPolicies.clear();
    alertedServiceConnectors.clear();
    topAlertedUser.clear();

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('generated')
          .where('close', isGreaterThanOrEqualTo: startDate)
          .where('close', isLessThanOrEqualTo: endDate)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // แปลง severity เป็น int
        final dynamic severityVal = data['severity'];
        final int? severity = severityVal is int
            ? severityVal
            : int.tryParse(severityVal.toString());

        if (severity == null) continue;

        // ดึงฟิลด์ id และ name
        // สมมติใน Firestore มี data['id'] เป็นตัวเลข, data['name'] เป็น string
        final String itemId = data['id']?.toString() ?? doc.id;
        final String itemName = data['name']?.toString() ?? 'NoName';

        // สร้าง key เฉพาะ (เช่น "id|name") เพื่อกันการซ้ำ
        final String combinedKey = "$itemId|$itemName";

        // เลือกกลุ่มตาม severity
        if (severity == 4) {
          // Policies
          _updateMap(topAlertedPolicies, combinedKey, itemId, itemName);
        } else if (severity == 3 || severity == 2) {
          // Connectors
          _updateMap(alertedServiceConnectors, combinedKey, itemId, itemName);
        } else if (severity == 1) {
          // User
          _updateMap(topAlertedUser, combinedKey, itemId, itemName);
        }
      }
    } catch (e) {
      print("❌ Error fetching alerted data: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  /// ฟังก์ชันอัปเดตข้อมูลใน Map
  void _updateMap(
    Map<String, Map<String, dynamic>> targetMap,
    String key,
    String id,
    String name,
  ) {
    if (targetMap.containsKey(key)) {
      // ถ้ามี key อยู่แล้ว บวก count
      targetMap[key]!['count'] = (targetMap[key]!['count'] as int) + 1;
    } else {
      // ถ้ายังไม่มี key สร้างใหม่
      targetMap[key] = {
        'count': 1,
        'id': id,
        'name': name,
      };
    }
  }

  /// แปลง Map => List เพื่อเรียงตาม count
  List<Map<String, dynamic>> _getSortedList(
    Map<String, Map<String, dynamic>> dataMap, {
    int topN = 5,
  }) {
    // เอา value ของ map มาทำเป็น List
    List<Map<String, dynamic>> list = dataMap.values.toList();
    // เรียงตาม count (มาก -> น้อย)
    list.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    // ตัดให้เหลือ topN
    if (list.length > topN) {
      list = list.sublist(0, topN);
    }
    return list;
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> dataList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (dataList.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 8),
            child: Text("No Data", style: TextStyle(fontSize: 16)),
          )
        else
          ...dataList.map(
            (item) => Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              // แสดง " id name"
              child:Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text("${item['id']}",style: const TextStyle(fontSize: 16)),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text("${item['name']}",style: const TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
            ),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final policiesList = _getSortedList(topAlertedPolicies);
    final connectorsList = _getSortedList(alertedServiceConnectors);
    final userList = _getSortedList(topAlertedUser);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26, // สีเงา
            blurRadius: 12,         // ความเบลอของเงา
            offset: const Offset(0, 4), // ตำแหน่งเงา (x, y)
          ),
        ],
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection("Top Alerted Policies", policiesList),
                const SizedBox(height: 16),
                _buildSection("Alerted Service Connectors", connectorsList),
                const SizedBox(height: 16),
                _buildSection("Top Alerted User", userList),
              ],
            ),
    );
  }
}
