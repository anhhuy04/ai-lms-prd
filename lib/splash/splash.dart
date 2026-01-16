import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return _build();
  }
}
Widget _build(){
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(
        // Đây là nơi bạn thường xuyên thay đổi code
        backgroundColor: Colors.blue,
        title: Text("Tiêu đề", textAlign: TextAlign.center),
      ),
      body: const Text(
        'dhfauifthiuahdìu'
            '4564ưq8549',
        textAlign: TextAlign.right,
        maxLines: 1,
        overflow: TextOverflow.clip,
      ),
    ),
  );
}
