import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html; // For controlling browser history
import 'Admin Constants/Admin_Constants.dart';
import 'Admin Constants/Admin_Responsive.dart';
import 'Screens/Components/side_menu.dart';
import 'controllers/menu_app_controller.dart';

class Adminscreen extends StatelessWidget {
  const Adminscreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Adding an entry to prevent back button navigation
    html.window.history.pushState(null, '', html.window.location.href);
    html.window.onPopState.listen((event) {
      // Re-add an entry when the user presses back button
      html.window.history.pushState(null, '', html.window.location.href);
    });

    return WillPopScope(
      onWillPop: () async {
        // Prevent back button action
        return false;
      },
      child: Scaffold(
        backgroundColor: bgColor,
        key: context.read<MenuAppController>().scaffoldKey,
        drawer: const SideMenu(),
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Side menu for large screens
              if (Responsive.isDesktop(context))
                const Expanded(
                  child: SideMenu(),
                ),
              // Main content area
              Expanded(
                flex: 5,
                child: Consumer<MenuAppController>(
                  builder: (context, menuController, child) {
                    return menuController.currentScreen;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
