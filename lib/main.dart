import 'package:campus_notice_app/Screens/Login_screen.dart';
import 'package:campus_notice_app/Screens/Navigation_bar/Home%20Screen/Home_page.dart';
import 'package:campus_notice_app/Screens/SignUp_screen.dart';
import 'package:campus_notice_app/Screens/Splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'as fb_auth;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:campus_notice_app/controllers/update_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:campus_notice_app/Services/Supabase_client.dart';
import 'package:campus_notice_app/Services/supabase_storage_service.dart';
import 'package:campus_notice_app/Services/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart'as supa;



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SupabaseConfig.initialize(); // ✅ ye sahi method call hai
  await GetStorage.init();

  Get.put(UpdateController());

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.light,
    darkTheme: ThemeData(brightness: Brightness.light),
    home: AuthChecker(),
  ));
}


// 👇 This widget decides where to go based on login state
class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    fb_auth.User? user = fb_auth.FirebaseAuth.instance.currentUser;

    if (user != null) {
      // ✅ Already logged in
      return HomePage();
    } else {
      // ❌ Not logged in
      return LoginScreen();
    }
  }
}
