import 'package:flutter/material.dart';

class IncidentFilter extends StatelessWidget {
  final int selectedFilter;
  final Function(int) onFilterChanged;

  const IncidentFilter({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterButton("All Incident", 0),
          const SizedBox(width: 4),
          _buildFilterButton("Generated XDR Agent", 1),
          const SizedBox(width: 4),
          _buildFilterButton("Generated PAN NGFW", 2),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String title, int filterValue) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => onFilterChanged(filterValue),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedFilter == filterValue ? Colors.green[900] : Colors.white,
          foregroundColor: selectedFilter == filterValue ? Colors.white : Colors.green[900],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
