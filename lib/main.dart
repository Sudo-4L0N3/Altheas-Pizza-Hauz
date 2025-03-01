import 'package:altheas_pizza_hauz/Login/Screens/Login/login_screen.dart';
import 'package:altheas_pizza_hauz/Login/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'Users/Admin/controllers/menu_app_controller.dart';
import 'Users/Customers/components/Cart Components/cart_model.dart';
import 'Users/Customers/customersScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "Insert API",
        authDomain: "altheas-pizza-hauz.firebaseapp.com",
        projectId: "altheas-pizza-hauz",
        storageBucket: "altheas-pizza-hauz.appspot.com",
        messagingSenderId: "1037001455369",
        appId: "1:1037001455369:web:50b46a4535b1aa3850c5d8",
        measurementId: "G-VG1TVNT2D7",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('cartBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => MenuAppController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Althea\'s Pizza Haus and Restaurant',
        theme: ThemeData(
          primaryColor: kPrimaryColor,
          fontFamily: 'Montserrat',
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: kPrimaryColor,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: kPrimaryLightColor,
            iconColor: kPrimaryColor,
            prefixIconColor: kPrimaryColor,
            contentPadding: EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Capture the URL parameters
    final uri = Uri.base;
    final String userType = uri.queryParameters['user'] ?? 'customer';

    if (userType == 'admin') {
      // Show login screen for admin
      return const LoginScreen();
    } else {
      // Automatically redirect customers to their dashboard
      return const CustomersScreen();
    }
  }
}
