import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routers/app_routes.dart';

class BkkScreen extends StatelessWidget {
  const BkkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bkk Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'หน้ารอโหลดข้อมูลเบื้องต้น',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // กดแล้วไปหน้า Home
                Get.offAllNamed(AppRoutes.HOME);
              },
              child: const Text('ไปหน้า Home'),
            ),
          ],
        ),
      ),
    );
  }
}
