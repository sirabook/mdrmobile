import 'package:flutter/material.dart';

class EndpointControlPanel extends StatelessWidget {
  final int selectedEntries;
  final bool isAscending;
  final String searchQuery;
  final Function(int) onEntriesChanged;
  final Function() onToggleSort;
  final Function(String) onSearchChanged;

  const EndpointControlPanel({
    Key? key,
    required this.selectedEntries,
    required this.isAscending,
    required this.searchQuery,
    required this.onEntriesChanged,
    required this.onToggleSort,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[800],
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Text("Show", style: TextStyle(color: Colors.white)),
          SizedBox(width: 8),
          DropdownButton<int>(
            value: selectedEntries,
            dropdownColor: Colors.green[700],
            style: TextStyle(color: Colors.white),
            items: [
              DropdownMenuItem<int>(
                value: 25,
                child: Text("25"),
              ),
              DropdownMenuItem<int>(
                value: 50,
                child: Text("50"),
              ),
              DropdownMenuItem<int>(
                value: 100,
                child: Text("100"),
              ),
              DropdownMenuItem<int>(
                value: -1,
                child: Text("All"),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onEntriesChanged(value);
              }
            },
          ),
          IconButton(
            icon: Icon(
              isAscending ? Icons.arrow_drop_down : Icons.arrow_drop_up,
              color: Colors.white,
            ),
            onPressed: onToggleSort,
          ),
          Spacer(),
          Text("Search:", style: TextStyle(color: Colors.white)),
          SizedBox(width: 8),
          Expanded(flex: 2,child: _buildSearchBox()),
        ],
      ),
    );
  }
  
  Widget _buildSearchBox() {
    return TextField(
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
      ),
      onChanged: onSearchChanged,
    );
  }
}
