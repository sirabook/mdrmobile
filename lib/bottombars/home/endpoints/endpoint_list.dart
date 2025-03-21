import 'package:flutter/material.dart';
import 'list/endpoint_tab_menu.dart';
import 'list/endpoint_control_panel.dart';
import 'list/endpoint_details.dart';

class EndpointList extends StatefulWidget {
  @override
  _EndpointListState createState() => _EndpointListState();
}

class _EndpointListState extends State<EndpointList> {
  int selectedEntries = 25;
  String searchQuery = "";
  bool isEndpointInfo = true;
  bool isAscending = true;
  Map<int, bool> expandedMap = {};

  @override
  Widget build(BuildContext context) {
    return Container(  // เปลี่ยนจาก Scaffold เป็น Container
      color: const Color.fromARGB(255, 255, 240, 199),
      child: Column(
        children: [
          EndpointTabMenu(
            isEndpointInfo: isEndpointInfo,
            onTabSelected: (bool value) {
              setState(() {
                isEndpointInfo = value;
              });
            },
          ),
          EndpointControlPanel(
            selectedEntries: selectedEntries,
            isAscending: isAscending,
            searchQuery: searchQuery,
            onEntriesChanged: (value) {
              setState(() {
                selectedEntries = value;
              });
            },
            onToggleSort: () {
              setState(() {
                isAscending = !isAscending;
              });
            },
            onSearchChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          Expanded(
            child: EndpointDetails(
              isEndpointInfo: isEndpointInfo,
              selectedEntries: selectedEntries,
              isAscending: isAscending,
              searchQuery: searchQuery,
              expandedMap: expandedMap,
              onToggleExpand: (endpointId) {
                setState(() {
                  expandedMap[endpointId] = !(expandedMap[endpointId] ?? false);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
