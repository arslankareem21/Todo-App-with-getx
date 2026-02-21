import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:getx_app/controller/auth_controller.dart';
import 'package:getx_app/view/login_view.dart';
import 'package:getx_app/view/register_view.dart';
import 'package:getx_app/view/todo_view.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Put AuthController immediately so it's available everywhere
  Get.put(AuthController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    
    final initialRoute = auth.user != null ? '/todo' : '/register';

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GetX Auth Todo Web',
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/register', page: () => RegisterView()),
        GetPage(name: '/login', page: () => LoginView()),
        GetPage(name: '/todo', page: () => TodoView()),
      ],
    );
  }
}
