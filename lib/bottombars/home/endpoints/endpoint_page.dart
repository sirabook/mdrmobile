import 'package:flutter/material.dart';
import 'package:mdr_mobile/bottombars/home/endpoints/endpoint_list.dart';
import 'package:mdr_mobile/bottombars/home/endpoints/endpoint_status.dart';

class EndpointPage extends StatefulWidget {
  const EndpointPage({Key? key}) : super(key: key);

  @override
  _EndpointPageState createState() => _EndpointPageState();
}

class _EndpointPageState extends State<EndpointPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 255, 240, 199),
      child: SafeArea(  // ป้องกัน Widget ชนขอบหน้าจอ
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      child: Text(
                        "Endpoint",
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
                    EndpointStatus(),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: constraints.maxHeight, // ป้องกัน Overflow
                      child: EndpointList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
