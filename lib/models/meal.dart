import '';

class Meal {
  final String id;
  final String name;
  final String thumbnail;
  final String instructicon;
  final Map<String, dynamic> ingredients; // key: ingredient, value: measure

  // constructor ของคลาส โดยกำหนดให้ต้องมส่งค่าทุกตัวแปรมา
  Meal({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.instructicon,
    required this.ingredients,
  });
  //สร้าง factory constructor เพื่อสร้าง Meal จากข้อมูล JSON
  factory Meal.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> ingredients = {}; // สร้าง Map ว่างสำหรับเก็บส่วนผสม
    for (int i = 1; i <= 20; i++) {
      //loop 1-20 เพราะ API กำหนด ส่วนผสมไว้ 20 แยกกัน
      final ingredient =
          json['strIngredient$i']; //ดึงข้อมูลส่วนผสมและปริมาณจาก JSON โดยใช้การแทรกเลข i เช่น strIngredient1, strMeasure1 ไปเรื่อยๆ
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        //เช็คว่า ingredient ไม่เป็น null และไม่ใช่สตริงว่าง (หลัง trim)  ถ้าผ่านเงื่อนไข เอาส่วนผสมเป็น key และปริมาณเป็น value ใส่ใน Map ingredients
        ingredients[ingredient] =
            measure ?? ''; //ถ้า measure เป็น null จะใช้ค่าว่าง ''
      }
    }

    //คืนค่า Meal object โดยใช้ข้อมูลที่ดึงมาและ Map ส่วนผสมที่สร้างขึ้น
    return Meal(
      id: json['idMeal'],
      name: json['strMeal'],
      thumbnail: json['strMealThumb'],
      instructicon: json['strInstructions'],
      ingredients: ingredients,
    );
  }


  
}
