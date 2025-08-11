import 'package:get/get.dart';
import '../utils/navigation_helper.dart';

// AuthController สำหรับจัดการ state ของการ authentication
class AuthController extends GetxController {
  // Observable variables
  final _isLoggedIn = false.obs;
  final _isLoading = false.obs;
  final _currentUser = Rxn<User>();

  // Getters
  bool get isLoggedIn => _isLoggedIn.value;
  bool get isLoading => _isLoading.value;
  User? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    // ตรวจสอบสถานะการล็อกอินเมื่อเริ่มแอป
    _checkLoginStatus();
  }

  // ตรวจสอบสถานะการล็อกอิน
  Future<void> _checkLoginStatus() async {
    try {
      // ตรวจสอบจาก SharedPreferences หรือ Secure Storage
      // final token = await _storageService.getToken();
      // if (token != null && await _validateToken(token)) {
      //   _setLoggedIn(true);
      //   NavigationHelper.toHome(clearStack: true);
      // }
    } catch (e) {
      print('Error checking login status: $e');
    }
  }

  // ฟังก์ชันล็อกอิน
  Future<bool> login({required String email, required String password}) async {
    try {
      _setLoading(true);

      // จำลองการเรียก API
      await Future.delayed(const Duration(seconds: 2));

      // ตรวจสอบข้อมูล (จำลอง)
      if (email == 'test@test.com' && password == '123456') {
        final user = User(
          id: '1',
          email: email,
          firstName: 'Test',
          lastName: 'User',
        );

        _setCurrentUser(user);
        _setLoggedIn(true);

        // บันทึก token (จำลอง)
        // await _storageService.saveToken('fake_token_123');

        NavigationHelper.showSuccessSnackBar('เข้าสู่ระบบสำเร็จ');

        // นำทางไปหน้า Home
        // NavigationHelper.toHome(clearStack: true);

        return true;
      } else {
        NavigationHelper.showErrorSnackBar('อีเมลหรือรหัสผ่านไม่ถูกต้อง');
        return false;
      }
    } catch (e) {
      NavigationHelper.showErrorSnackBar('เกิดข้อผิดพลาด: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ฟังก์ชันสมัครสมาชิก
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);

      // จำลองการเรียก API
      await Future.delayed(const Duration(seconds: 2));

      // ตรวจสอบว่าอีเมลซ้ำหรือไม่ (จำลอง)
      if (email == 'existing@test.com') {
        NavigationHelper.showErrorSnackBar('อีเมลนี้ถูกใช้งานแล้ว');
        return false;
      }

      NavigationHelper.showSuccessSnackBar('สมัครสมาชิกสำเร็จ');

      // กลับไปหน้า Login
      await Future.delayed(const Duration(milliseconds: 1500));
      NavigationHelper.offNamed('/login');

      return true;
    } catch (e) {
      NavigationHelper.showErrorSnackBar('เกิดข้อผิดพลาด: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ฟังก์ชันรีเซ็ตรหัสผ่าน
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);

      // จำลองการเรียก API
      await Future.delayed(const Duration(seconds: 2));

      NavigationHelper.showSuccessSnackBar(
        'ส่งลิงก์รีเซ็ตรหัสผ่านไปยังอีเมลของคุณแล้ว',
      );

      return true;
    } catch (e) {
      NavigationHelper.showErrorSnackBar('เกิดข้อผิดพลาด: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ฟังก์ชันล็อกเอาต์
  Future<void> logout() async {
    try {
      _setLoading(true);

      // ลบ token และข้อมูลผู้ใช้
      // await _storageService.deleteToken();

      _setLoggedIn(false);
      _setCurrentUser(null);

      NavigationHelper.showSuccessSnackBar('ออกจากระบบแล้ว');
      NavigationHelper.toLogin(clearStack: true);
    } catch (e) {
      NavigationHelper.showErrorSnackBar('เกิดข้อผิดพลาด: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading.value = value;
  }

  void _setLoggedIn(bool value) {
    _isLoggedIn.value = value;
  }

  void _setCurrentUser(User? user) {
    _currentUser.value = user;
  }
}

// User model
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImage;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImage,
  });

  String get fullName => '$firstName $lastName';

  // Convert to/from JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImage: json['profileImage'],
    );
  }
}

// Binding สำหรับ Dependency Injection
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
