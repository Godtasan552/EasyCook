import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routers/app_routes.dart';

class BkkScreen extends StatelessWidget {
  const BkkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6B6B), // สีแดงอ่อน
              Color(0xFFFF8E53), // สีส้ม
              Color(0xFFFFD93D), // สีเหลือง
            ],
          ),
        ),
        child: Stack(
          children: [
            // ลวดลายพื้นหลัง
            Positioned.fill(
              child: _buildBackgroundPattern(),
            ),
            
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    // ส่วนบน - Logo และชื่อแอป
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo/Icon ของแอป
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
                              size: 60,
                              color: Color(0xFFFF6B6B),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // ชื่อแอป
                          const Text(
                            'EasyCook',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // คำอธิบาย
                          const Text(
                            'ทำอาหารง่าย ๆ ได้ทุกเมื่อ',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // ช่องว่างตรงกลาง
                    const Spacer(flex: 2),
                    
                    // ส่วนล่าง - ปุ่มและไอคอน
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // ปุ่มไปหน้า Home
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.offAllNamed(AppRoutes.HOME);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFFF6B6B),
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.home,
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'เริ่มต้นใช้งาน',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // ฟีเจอร์หลักของแอป
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // ค้นหาสูตรอาหาร
                                _buildFeatureItem(
                                  icon: Icons.search,
                                  title: 'ค้นหา',
                                  subtitle: '',
                                ),
                                
                                // เส้นแบ่ง
                                Container(
                                  height: 60,
                                  width: 1,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                                
                                // สูตรที่ชอบ
                                _buildFeatureItem(
                                  icon: Icons.favorite,
                                  title: 'สูตรที่ชอบ',
                                  subtitle: '',
                                ),
                                
                                // เส้นแบ่ง
                                Container(
                                  height: 60,
                                  width: 1,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                                
                                // ขั้นตอนง่ายดาย
                                _buildFeatureItem(
                                  icon: Icons.auto_awesome,
                                  title: 'ขั้นตอนง่าย',
                                  subtitle: '',
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12), // แก้จาก 😎 เป็น 12
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8), // แก้จาก 😎 เป็น 8
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 10,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildBackgroundPattern() {
    return Opacity(
      opacity: 0.12,
      child: Stack(
        children: [
          // สร้างรูปแบบ grid แบบ Louis Vuitton
          for (int row = 0; row < 12; row++)
            for (int col = 0; col < 6; col++)
              _buildIconPattern(row, col),
        ],
      ),
    );
  }
  
  Widget _buildIconPattern(int row, int col) {
    // ระยะห่างแนวนอนและแนวตั้ง
    const double horizontalSpacing = 70.0;
    const double verticalSpacing = 65.0;
    const double startX = 25.0;
    const double startY = 40.0;
    
    // รายการไอคอนอาหาร
    final List<IconData> foodIcons = [
      Icons.restaurant,
      Icons.local_pizza,
      Icons.rice_bowl,
      Icons.coffee,
      Icons.cake,
      Icons.lunch_dining,
      Icons.fastfood,
      Icons.icecream,
      Icons.local_dining,
      Icons.breakfast_dining,
      Icons.dinner_dining,
      Icons.bakery_dining,
      Icons.set_meal,
      Icons.ramen_dining,
      Icons.egg_alt,
      Icons.local_bar,
    ];
    
    // คำนวณตำแหน่ง
    double x = startX + (col * horizontalSpacing);
    double y = startY + (row * verticalSpacing);
    
    // สำหรับ offset แบบ brick pattern (เหมือน Louis Vuitton)
    if (row % 2 == 1) {
      x += horizontalSpacing / 2;
    }
    
    // เลือกไอคอนแบบวนรอบ
    int iconIndex = (row * 6 + col) % foodIcons.length;
    
    // ขนาดไอคอนสลับกัน
    double iconSize = (row + col) % 3 == 0 ? 32 : 
                     (row + col) % 3 == 1 ? 28 : 30;
    
    return Positioned(
      left: x,
      top: y,
      child: Transform.rotate(
        angle: (row + col) % 4 * 0.1, // หมุนเล็กน้อยเพื่อความสวยงาม
        child: Container(
          width: iconSize + 8,
          height: iconSize + 8,
          decoration: BoxDecoration(
            // เพิ่มพื้นหลังโปร่งใส
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12), // แก้จาก 😎 เป็น 12
          ),
          child: Icon(
            foodIcons[iconIndex],
            size: iconSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
