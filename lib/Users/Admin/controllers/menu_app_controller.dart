import 'package:flutter/material.dart';
import '../Screens/New Dashbaord/dashboard_screen.dart';
// Import other screens as needed

class MenuAppController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  // Variable to keep track of the current screen
  Widget _currentScreen = const DashboardScreen(); // Set initial screen

  Widget get currentScreen => _currentScreen;

  void changeScreen(Widget screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }
}
