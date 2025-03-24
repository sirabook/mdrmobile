import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'incidents_card.dart';
import 'incidents_filter.dart';

class IncidentsList extends StatefulWidget {
  final int? selectedDays;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;

  const IncidentsList({
    Key? key,
    this.selectedDays,
    this.selectedStartDate,
    this.selectedEndDate,
  }) : super(key: key);

  @override
  _IncidentsListState createState() => _IncidentsListState();
}

class _IncidentsListState extends State<IncidentsList> {
  // ใช้ -1 แทนตัวเลือก All
  int selectedEntries = 25; 
  String searchQuery = "";
  int selectedFilter = 0; // 0 = All, 1 = XDR Agent, 2 = PAN NGFW
  bool sortAscending = true; // true: น้อยไปมาก, false: มากไปน้อย

  late Stream<QuerySnapshot> _incidentStream;

  @override
  void initState() {
    super.initState();
    // ดึงข้อมูลจาก Firestore (Collection 'generated')
    _incidentStream =
        FirebaseFirestore.instance.collection('generated').snapshots();
  }

  /// ฟังก์ชันกรองข้อมูลตามเงื่อนไข
  List<QueryDocumentSnapshot> _filterIncidents(
      List<QueryDocumentSnapshot> incidents) {
    final DateTime now = DateTime.now();
    final DateTime startDate = widget.selectedStartDate ??
        now.subtract(Duration(days: widget.selectedDays ?? 7));
    final DateTime endDate = widget.selectedEndDate ?? now;

    // กรองข้อมูลตามเงื่อนไข
    List<QueryDocumentSnapshot> filtered = incidents.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // 1) ตรวจสอบ timestamp (close)
      final Timestamp? closeTS = data['close'] as Timestamp?;
      if (closeTS == null) return false;
      final DateTime incidentDate = closeTS.toDate();
      if (incidentDate.isBefore(startDate) || incidentDate.isAfter(endDate)) {
        return false;
      }

      // 2) ตรวจสอบประเภท (gen): 1 = XDR Agent, 2 = PAN NGFW
      if (selectedFilter == 1 && data['gen'] != 1) return false;
      if (selectedFilter == 2 && data['gen'] != 2) return false;

      // 3) ค้นหาด้วย name และ id
      final String name = (data['name'] ?? '').toString().toLowerCase();
      final String idStr = (data['id'] ?? '').toString();
      final String query = searchQuery.toLowerCase();
      if (query.isNotEmpty) {
        if (!(name.contains(query) || idStr.contains(query))) {
          return false;
        }
      }
      return true;
    }).toList();

    // เรียงข้อมูลตาม id (id ใน Firestore เป็น int)
    filtered.sort((a, b) {
      final int idA = (a.data() as Map<String, dynamic>)['id'] ?? 0;
      final int idB = (b.data() as Map<String, dynamic>)['id'] ?? 0;
      return sortAscending ? idA.compareTo(idB) : idB.compareTo(idA);
    });

    // ถ้า selectedEntries เท่ากับ -1 ให้ return ทั้งหมด (All)
    if (selectedEntries == -1) {
      return filtered;
    }

    // จำกัดจำนวนรายการที่จะแสดง
    return filtered.take(selectedEntries).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 240, 199),
      body: Column(
        children: [
          // ปุ่ม filter "All Incident", "Generated XDR Agent", "Generated PAN NGFW"
          IncidentsFilter(
            selectedFilter: selectedFilter,
            onFilterChanged: (filter) => setState(() => selectedFilter = filter),
          ),
          // ส่วน Dropdown, Search และปุ่มเรียงข้อมูล
          _buildSearchAndDropdown(),
          // ส่วนแสดงรายการ Incident
          Expanded(
            child: Container(
              color: Colors.green[900],
              child: StreamBuilder<QuerySnapshot>(
                stream: _incidentStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No incidents found",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    );
                  }
                  final List<QueryDocumentSnapshot> filteredIncidents =
                      _filterIncidents(snapshot.data!.docs);

                  if (filteredIncidents.isEmpty) {
                    return const Center(
                      child: Text(
                        "No incidents match your filter",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredIncidents.length,
                    itemBuilder: (context, index) {
                      final data = filteredIncidents[index].data()
                          as Map<String, dynamic>;
                      return IncidentsCard(data: data);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// สร้างแถบ Search, Dropdown และปุ่มเรียงข้อมูล
  Widget _buildSearchAndDropdown() {
    return Container(
      color: Colors.green[900],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text("Show", style: TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          DropdownButton<int>(
            // ค่า -1 แทน All
            value: selectedEntries,
            dropdownColor: Colors.green[700],
            style: const TextStyle(color: Colors.white),
            items: [
              DropdownMenuItem<int>(
                value: 25,
                child: const Text("25"),
              ),
              DropdownMenuItem<int>(
                value: 50,
                child: const Text("50"),
              ),
              DropdownMenuItem<int>(
                value: 100,
                child: const Text("100"),
              ),
              DropdownMenuItem<int>(
                value: -1,
                child: const Text("All"),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedEntries = value!;
              });
            },
          ),
          const SizedBox(width: 16),
          // ปุ่มเรียงข้อมูล (sort) พร้อมแสดงไอคอนตามสถานะ
          IconButton(
            icon: Icon(
              sortAscending ? Icons.arrow_drop_down : Icons.arrow_drop_up,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                // สลับการเรียงจากน้อยไปมากและมากไปน้อย
                sortAscending = !sortAscending;
              });
            },
          ),
          const Spacer(),
          const Text("Search:", style: TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextField(
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
