import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const HexGridApp());
}

class HexGridApp extends StatelessWidget {
  const HexGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: const Text("Hex Grid Renderer")),
        body: const HexGrid(),
        backgroundColor: Colors.grey[850],
      ),
    );
  }
}

class HexGrid extends StatefulWidget {
  const HexGrid({super.key});

  @override
  HexGridState createState() => HexGridState();
}

class HexGridState extends State<HexGrid> {
  List<List<int>> numbers = [];
  int N = 0;

  @override
  void initState() {
    super.initState();
    loadFile();
  }

  void loadFile() async {
    String file = await rootBundle.loadString('assets/3.txt');
    List<String> lines = file.trim().split('\n');
    setState(() {
      N = int.parse(lines[0].trim());
      numbers = lines.sublist(1).map((line) {
        return line.split(',').map((String num) => int.parse(num.trim())).toList();
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (numbers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomPaint(
      size: Size.infinite,
      painter: HexGridPainter(numbers, N),
    );
  }
}

class HexGridPainter extends CustomPainter {
  final List<List<int>> numbers;
  final int N;
  final double hexRadius = 30.0;

  HexGridPainter(this.numbers, this.N);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint hexPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey[300]!;

    final double hexHeight = hexRadius * 2;
    final double hexWidth = sqrt(3) * hexRadius;
    const double hexSpacing = 5.0;

    double baseFontSize = 12;
    double dynamicFontSize = max(baseFontSize * (7 / N), 4);

    final textStyle = TextStyle(
      color: Colors.grey[300],
      fontSize: dynamicFontSize,
    );

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    double gridHeight = (numbers.length - 1) * (hexHeight * 0.75 + hexSpacing);
    double verticalShift = gridHeight / 2;
    double canvasCenterX = size.width / 2;
    double canvasCenterY = size.height / 2;

    for (int row = 0; row < numbers.length; row++) {
      double y = (row * (hexHeight * 0.75 + hexSpacing)) - verticalShift;

      double rowOffset = -(numbers[row].length - 1) / 2;
      for (int col = 0; col < numbers[row].length; col++) {
        double x = (col + rowOffset) * (hexWidth + hexSpacing);

        Offset center = Offset(canvasCenterX + x, canvasCenterY + y);
        drawHexagon(canvas, center, hexRadius, hexPaint);

        int num = numbers[row][col];
        if (num != 0) {
          textPainter.text = TextSpan(
            text: num.toString(),
            style: textStyle,
          );
          textPainter.layout();
          textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
        }
      }
    }
  }

  void drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    Path path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (pi / 3) * i - (pi / 6);
      double x = radius * cos(angle) + center.dx;
      double y = radius * sin(angle) + center.dy;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
