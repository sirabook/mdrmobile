import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; 

class IncidentSummary extends StatefulWidget {
  final int? selectedDays;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;

  const IncidentSummary({
    Key? key,
    this.selectedDays,
    this.selectedStartDate,
    this.selectedEndDate,
  }) : super(key: key);

  @override
  _IncidentSummaryState createState() => _IncidentSummaryState();
}

class _IncidentSummaryState extends State<IncidentSummary> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  List<List<double>> data = [];
  List<String> locationList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didUpdateWidget(covariant IncidentSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDays != widget.selectedDays ||
        oldWidget.selectedStartDate != widget.selectedStartDate ||
        oldWidget.selectedEndDate != widget.selectedEndDate) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
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

      // สร้าง map แบบไดนามิกตาม location ที่ได้จาก Firebase
      Map<String, List<double>> incidentMap = {};

      for (var doc in snapshot.docs) {
        var docData = doc.data() as Map<String, dynamic>;
        String location = docData["location"] ?? "Unknown";
        int severity = docData["severity"] ?? 0;

        if (!incidentMap.containsKey(location)) {
          incidentMap[location] = [0, 0, 0, 0];
        }

        // แบ่งกลุ่มตามค่า severity: 1 = low, 2 = medium, 3 = high, 4 = critical
        if (severity == 1) {
          incidentMap[location]![0] += 1;
        } else if (severity == 2) {
          incidentMap[location]![1] += 1;
        } else if (severity == 3) {
          incidentMap[location]![2] += 1;
        } else if (severity == 4) {
          incidentMap[location]![3] += 1;
        }
      }

      setState(() {
        locationList = incidentMap.keys.toList();
        data = incidentMap.values.toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching incident summary: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25),
            SizedBox(
              height: 220,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildChart(),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  double _getMaxYValue() {
    double currentMax = 0;
    for (List<double> group in data) {
      for (double value in group) {
        if (value > currentMax) {
          currentMax = value;
        }
      }
    }
    return currentMax * 1.4; // เพิ่มพื้นที่ด้านบน 40%
  }

  Widget _buildChart() {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = locationList.length * 70.0; // กำหนดความกว้างต่อแต่ละกลุ่ม
    final chartWidth = max(contentWidth, screenWidth);
    double maxY = _getMaxYValue();

    Widget chart = Container(
      width: chartWidth,
      child: BarChart(
        BarChartData(
          maxY: maxY, // เพื่อไม่ให้ tooltip ถูก clip
          groupsSpace: 20,
          barGroups: _getBarGroups(),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= locationList.length) return Container();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Container(
                      width: 60,
                      child: Text(
                        locationList[index],
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.transparent,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toInt().toString(),
                  const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
            ),
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );

    // ถ้าข้อมูลน้อย ไม่ต้องห่อด้วย SingleChildScrollView
    if (contentWidth <= screenWidth) {
      return chart;
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: chart,
      );
    }
  }

  List<BarChartGroupData> _getBarGroups() {
    List<Color> colors = [Colors.green, Colors.blueAccent, Colors.orange, Colors.red];

    return List.generate(data.length, (index) {
      List<BarChartRodData> rods = [];
      for (int i = 0; i < data[index].length; i++) {
        if (data[index][i] > 0) {
          rods.add(
            BarChartRodData(
              toY: data[index][i],
              color: colors[i],
              width: 10,
              borderRadius: BorderRadius.zero,
            ),
          );
        }
      }

      if (rods.isEmpty) return null; // ถ้าทุกค่าเป็น 0 ให้ข้ามไปเลย

      return BarChartGroupData(
        x: index,
        barRods: rods,
        showingTooltipIndicators: List.generate(rods.length, (i) => i),
        barsSpace: 8,
      );
    }).whereType<BarChartGroupData>().toList();
  }
}
