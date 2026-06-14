import 'dart:convert';
import 'dart:io';

void main() async {
  final process = await Process.run('curl', ['-s', 'https://pub.dev/api/packages/floodfill_image']);
  print('floodfill_image: ' + process.stdout.toString().substring(0, 500));
  
  final process2 = await Process.run('curl', ['-s', 'https://pub.dev/api/packages/floodfill_span']);
  print('floodfill_span: ' + process2.stdout.toString().substring(0, 500));
}
