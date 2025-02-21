import 'package:flutter/material.dart';
import 'package:headsup/pages/const/theme.dart';

class PlayerContainer extends StatelessWidget {
  final String name;
  final int score;
  const PlayerContainer({super.key, required this.name, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2.0,vertical: 5.0),
      child: Stack(
        children: [
           Align(
           alignment: Alignment.centerRight,
            child:Image.asset("assets/images/green_banner.png",
              height: 50,
              width: 300,
              fit:BoxFit.cover,
              ),
          ),
                  Positioned(
                    left: 50,
                    child: Text("$name",
                    style: TextStyle(fontSize: 40,color: AppColors.playerCardColor,fontFamily: AppTheme.fontName,fontWeight: FontWeight.w500
                    ),
                    overflow: TextOverflow.ellipsis,
                    )
                    ),      
        ],
      ),
    );
  }
}