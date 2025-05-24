import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final Color color;
  final double iconsize;

  StarRating(
      {this.rating = 0.0, this.starCount = 5, this.color = Colors.orange, required this.iconsize});

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = new Icon(
        Icons.star_border,
        color: color,
        size: iconsize,
      );
    } else if (index > rating - 1 && index < rating) {
      icon = new Icon(
        Icons.star_half,
        color: color,
        size: iconsize,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: color,
        size: iconsize,
      );
    }
    return new InkResponse(
      onTap: () => {},
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      children:
          new List.generate(starCount, (index) => buildStar(context, index)),
    );
  }
}
