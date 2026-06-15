import 'package:flutter/material.dart';

/// Pure static math for generating ellipse coordinates using Midpoint Algorithm
class EllipseAlgorithms {
  static List<Offset> generateMidpointEllipse(Offset center, double rx, double ry) {
    final result = <Offset>[];
    
    double dx, dy, d1, d2, x, y;
    x = 0;
    y = ry;
    
    d1 = (ry * ry) - (rx * rx * ry) + (0.25 * rx * rx);
    dx = 2 * ry * ry * x;
    dy = 2 * rx * rx * y;

    // Region 1
    while (dx < dy) {
      _addSymmetricPoints(result, center, x, y);
      
      if (d1 < 0) {
        x++;
        dx = dx + (2 * ry * ry);
        d1 = d1 + dx + (ry * ry);
      } else {
        x++;
        y--;
        dx = dx + (2 * ry * ry);
        dy = dy - (2 * rx * rx);
        d1 = d1 + dx - dy + (ry * ry);
      }
    }

    // Region 2
    d2 = ((ry * ry) * ((x + 0.5) * (x + 0.5))) +
         ((rx * rx) * ((y - 1) * (y - 1))) -
         (rx * rx * ry * ry);

    while (y >= 0) {
      _addSymmetricPoints(result, center, x, y);

      if (d2 > 0) {
        y--;
        dy = dy - (2 * rx * rx);
        d2 = d2 + (rx * rx) - dy;
      } else {
        y--;
        x++;
        dx = dx + (2 * ry * ry);
        dy = dy - (2 * rx * rx);
        d2 = d2 + dx - dy + (rx * rx);
      }
    }

    return result;
  }

  static void _addSymmetricPoints(List<Offset> list, Offset center, double x, double y) {
    list.add(Offset(center.dx + x, center.dy + y));
    list.add(Offset(center.dx - x, center.dy + y));
    list.add(Offset(center.dx + x, center.dy - y));
    list.add(Offset(center.dx - x, center.dy - y));
  }
}
