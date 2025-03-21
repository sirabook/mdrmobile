import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class EndpointDetails extends StatelessWidget {
  final bool isEndpointInfo;
  final int selectedEntries;
  final bool isAscending;
  final String searchQuery;
  final Map<int, bool> expandedMap;
  final Function(int) onToggleExpand;

  const EndpointDetails({
    Key? key,
    required this.isEndpointInfo,
    required this.selectedEntries,
    required this.isAscending,
    required this.searchQuery,
    required this.expandedMap,
    required this.onToggleExpand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('endpoints').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var filteredData = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          int id = data['id'];
          String name = data['name'].toLowerCase();
          return id.toString().contains(searchQuery) ||
              name.contains(searchQuery.toLowerCase());
        }).toList();

        filteredData.sort((a, b) {
          int idA = (a.data() as Map<String, dynamic>)['id'];
          int idB = (b.data() as Map<String, dynamic>)['id'];
          return isAscending ? idA.compareTo(idB) : idB.compareTo(idA);
        });

        final int itemCount = selectedEntries == -1
            ? filteredData.length
            : min(filteredData.length, selectedEntries);

        return Container(
          color: Colors.green[800],
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              var data = filteredData[index].data() as Map<String, dynamic>;
              return _buildEndpointCard(data);
            },
          ),
        );
      },
    );
  }

  Widget _buildEndpointCard(Map<String, dynamic> data) {
    int endpointId = data['id'];
    bool isExpanded = expandedMap[endpointId] ?? false;

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => onToggleExpand(endpointId),
            ),
            title: isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ID: ${data['id']}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Endpoint Name: ${data['name']}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )
                : Text(
                    "ID: ${data['id']}  Endpoint Name: ${data['name']}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: isEndpointInfo
                  ? _buildEndpointInfoDetails(data)
                  : _buildEndpointActionDetails(data),
            ),
        ],
      ),
    );
  }

   Widget _buildEndpointInfoDetails(Map<String, dynamic> data) {
     int? status = data['status'];
  String statusText = (status == 1)
      ? "Connected"
      : (status == 2)
          ? "Disconnected"
          : "Unknown";
  return Align(
    alignment: Alignment.centerLeft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Text("Endpoint Type: ${data['type'] ?? 'Unknown'}"),
        Text("Operating System: ${data['os'] ?? 'Unknown'}"),
        Text("Endpoint Status: $statusText"),
        Text("Last Seen: ${_formatTimestamp(data['last_seen'])}"),
      ],
    ),
  );
}

  Widget _buildEndpointActionDetails(Map<String, dynamic> data) {
    int? isolateStatus = data['isolate_status'];
    int? status = data['status'];

    String statusText = (status == 1)
        ? "Connected"
        : (status == 2)
            ? "Disconnected"
            : "Unknown";

    String isolateStatusText = (isolateStatus == 1)
        ? "Unisolated"
        : (isolateStatus == 2)
            ? "Isolated"
            : "Unknown";

    bool isIsolated = (isolateStatus == 1); // ใช้สำหรับกำหนดค่า Switch

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Endpoint Status: $statusText"),
        Row(
          children: [
            Text("Isolate Status: "),
            Switch(
              value: isIsolated,
              onChanged: null,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.grey,
              activeTrackColor: Colors.grey,
            ),
            Text(isolateStatusText),
          ],
        ),
        Text("Scan Status: ${data['scan_status'] ?? 'Unknown'}"),
        Text("Last Seen: ${_formatTimestamp(data['last_seen'])}"),
      ],
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    return (timestamp is Timestamp)
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate())
        : "Unknown";
  }
}
