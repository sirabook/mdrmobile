import 'package:flutter/material.dart';

class EndpointTabMenu extends StatelessWidget {
  final bool isEndpointInfo;
  final Function(bool) onTabSelected;

  const EndpointTabMenu({
    Key? key,
    required this.isEndpointInfo,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTabButton("Endpoint Info", true),
        _buildTabButton("Endpoint Action", false),
      ],
    );
  }

  Widget _buildTabButton(String title, bool isInfoTab) {
    bool isSelected = isEndpointInfo == isInfoTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(isInfoTab),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green[800] : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isInfoTab ? 20 : 0),
              topRight: Radius.circular(!isInfoTab ? 20 : 0),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isSelected ? 18.0 : 14.0,
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
