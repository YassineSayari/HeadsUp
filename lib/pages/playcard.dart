import 'package:flutter/material.dart';
import 'package:headsup/pages/const/theme.dart';

class PlayCard extends StatelessWidget {
  final String topicImage;
  final String topic;
  final Function onPressed;

  PlayCard({
    required this.topicImage,
    required this.topic,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Container(
        width: 140,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  topicImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 5),
            Container(
              width: double.infinity, 
              decoration: AppTheme.playButtonDecoration,
              child: TextButton(
                onPressed: () => onPressed(),
                child: Text(
                  'Play $topic',
                  style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: AppTheme.homePlayFontSize,fontFamily: AppTheme.fontName),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
