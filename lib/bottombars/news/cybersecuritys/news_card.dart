import 'package:flutter/material.dart';
import 'news_detail.dart';

class NewsCard extends StatelessWidget {
  final Map<String, dynamic> news;
  const NewsCard({required this.news});
  
  @override
  Widget build(BuildContext context) {
     String imageUrl = news['img'] ?? '';

    // ใช้ Regular Expression เพื่อตัดทุกอย่างที่อยู่ก่อนหน้า http:// หรือ https://
    final regex = RegExp(r'^.*?(https?://.*)');
    final match = regex.firstMatch(imageUrl);
    if (match != null) {
      imageUrl = match.group(1)!;
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(news: news),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xFF134E41), // ✅ สีพื้นหลังเขียวเข้ม
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 80, color: Colors.white),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news['name'] ?? 'No Title',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    news['detail1'] ?? 'No Description',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
