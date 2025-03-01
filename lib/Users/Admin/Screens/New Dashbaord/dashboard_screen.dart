import 'package:altheas_pizza_hauz/Users/Admin/Screens/New%20Dashbaord/all_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Admin Constants/Admin_Constants.dart';
import '../../Admin Constants/Admin_Responsive.dart';
import 'recent_order.dart';
import 'top_foods.dart';
import 'dashboard_box.dart';
import 'package:altheas_pizza_hauz/Users/Admin/Screens/Components/side_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalOrdersCount = 0;
  int doneCount = 0;
  int pendingCount = 0;
  int pickedUpCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchOrderCounts();
  }

  // Function to fetch counts for Total, Done, Pending, and Picked-up Orders
  void _fetchOrderCounts() async {
    // Fetch all documents from Order collection to get the total count
    QuerySnapshot totalOrdersQuery = await FirebaseFirestore.instance
        .collection('Order')
        .get();

    // Fetch documents from Order collection where status is "Done"
    QuerySnapshot doneOrdersQuery = await FirebaseFirestore.instance
        .collection('Order')
        .where('status', isEqualTo: 'Done')
        .get();

    // Fetch documents from Order collection where status is "Pending"
    QuerySnapshot pendingOrdersQuery = await FirebaseFirestore.instance
        .collection('Order')
        .where('status', isEqualTo: 'Pending')
        .get();

    // Fetch documents from orderHistory collection where status is "Picked-up"
    QuerySnapshot pickedUpOrdersQuery = await FirebaseFirestore.instance
        .collection('orderHistory')
        .where('status', isEqualTo: 'Picked-up')
        .get();

    setState(() {
      totalOrdersCount = totalOrdersQuery.size;  // Total number of documents in Order collection
      doneCount = doneOrdersQuery.size;  // Number of "Done" orders
      pendingCount = pendingOrdersQuery.size;  // Number of "Pending" orders
      pickedUpCount = pickedUpOrdersQuery.size;  // Number of "Picked-up" orders in orderHistory
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Disable back button
        return false;
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: Responsive.isMobile(context)
            ? AppBar(
                title: const Text('Dashboard'),
                backgroundColor: primaryColor,
              )
            : null,
        drawer: Responsive.isMobile(context) ? const SideMenu() : null,
        body: SafeArea(
          child: Responsive(
            mobile: MobileDashboard(
                totalOrdersCount: totalOrdersCount, 
                doneCount: doneCount, 
                pendingCount: pendingCount, 
                pickedUpCount: pickedUpCount),
            tablet: TabletDashboard(
                totalOrdersCount: totalOrdersCount, 
                doneCount: doneCount, 
                pendingCount: pendingCount, 
                pickedUpCount: pickedUpCount),
            desktop: DesktopDashboard(
                totalOrdersCount: totalOrdersCount, 
                doneCount: doneCount, 
                pendingCount: pendingCount, 
                pickedUpCount: pickedUpCount),
          ),
        ),
      ),
    );
  }
}

class DesktopDashboard extends StatelessWidget {
  final int totalOrdersCount;
  final int doneCount;
  final int pendingCount;
  final int pickedUpCount;

  const DesktopDashboard({super.key, required this.totalOrdersCount, required this.doneCount, required this.pendingCount, required this.pickedUpCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              double totalSpacing = defaultPadding * 3;
              double boxWidth = (constraints.maxWidth - totalSpacing) / 4;

              if (boxWidth < 200) {
                return Wrap(
                  spacing: defaultPadding,
                  runSpacing: defaultPadding,
                  children: [
                    // Orders Box with dynamic count
                    SizedBox(
                      width: (constraints.maxWidth - defaultPadding) / 2,
                      child: DashboardBox(
                        title: 'Orders',
                        count: totalOrdersCount, // Dynamic total orders count
                        icon: Icons.shopping_cart,
                        color: secondaryColor,
                      ),
                    ),
                    // Done Box with dynamic count
                    SizedBox(
                      width: (constraints.maxWidth - defaultPadding) / 2,
                      child: DashboardBox(
                        title: 'Done',
                        count: doneCount,  // Dynamic "Done" orders count
                        icon: Icons.check_circle,
                        color: secondaryColor,
                      ),
                    ),
                    // Pending Box with dynamic count
                    SizedBox(
                      width: (constraints.maxWidth - defaultPadding) / 2,
                      child: DashboardBox(
                        title: 'Pending',
                        count: pendingCount,  // Dynamic "Pending" orders count
                        icon: Icons.pending,
                        color: secondaryColor,
                      ),
                    ),
                    // Picked-up Box with dynamic count from orderHistory
                    SizedBox(
                      width: (constraints.maxWidth - defaultPadding) / 2,
                      child: DashboardBox(
                        title: 'Picked-up',
                        count: pickedUpCount,  // Dynamic "Picked-up" count from orderHistory
                        icon: Icons.local_shipping,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                );
              }

              return Wrap(
                spacing: defaultPadding,
                runSpacing: defaultPadding,
                children: [
                  // Orders Box with dynamic count
                  SizedBox(
                    width: boxWidth,
                    child: DashboardBox(
                      title: 'Orders',
                      count: totalOrdersCount,  // Dynamic total orders count
                      icon: Icons.shopping_cart,
                      color: secondaryColor,
                    ),
                  ),
                  // Done Box with dynamic count
                  SizedBox(
                    width: boxWidth,
                    child: DashboardBox(
                      title: 'Done',
                      count: doneCount,  // Dynamic "Done" orders count
                      icon: Icons.check_circle,
                      color: secondaryColor,
                    ),
                  ),
                  // Pending Box with dynamic count
                  SizedBox(
                    width: boxWidth,
                    child: DashboardBox(
                      title: 'Pending',
                      count: pendingCount,  // Dynamic "Pending" orders count
                      icon: Icons.pending,
                      color: secondaryColor,
                    ),
                  ),
                  // Picked-up Box with dynamic count from orderHistory
                  SizedBox(
                    width: boxWidth,
                    child: DashboardBox(
                      title: 'Picked-up',
                      count: pickedUpCount,  // Dynamic "Picked-up" count from orderHistory
                      icon: Icons.local_shipping,
                      color: secondaryColor,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: defaultPadding * 1.5),
          const Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: AllMenu(),
                ),
                SizedBox(width: defaultPadding),
                SizedBox(
                  width: 300,
                  child: TopFoods(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// TabletDashboard - Similar to DesktopDashboard, but adapted for tablet screen size
class TabletDashboard extends StatelessWidget {
  final int totalOrdersCount;
  final int doneCount;
  final int pendingCount;
  final int pickedUpCount;

  const TabletDashboard({super.key, required this.totalOrdersCount, required this.doneCount, required this.pendingCount, required this.pickedUpCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              double totalSpacing = defaultPadding;
              double boxWidth = (constraints.maxWidth - totalSpacing) / 2;

              if (boxWidth < 200) {
                return Column(
                  children: [
                    // Orders Box with dynamic count
                    SizedBox(
                      width: constraints.maxWidth,
                      child: DashboardBox(
                        title: 'Orders',
                        count: totalOrdersCount,  // Dynamic total orders count
                        icon: Icons.shopping_cart,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    // Done Box with dynamic count
                    SizedBox(
                      width: constraints.maxWidth,
                      child: DashboardBox(
                        title: 'Done',
                        count: doneCount,  // Dynamic "Done" orders count
                        icon: Icons.check_circle,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    // Pending Box with dynamic count
                    SizedBox(
                      width: constraints.maxWidth,
                      child: DashboardBox(
                        title: 'Pending',
                        count: pendingCount,  // Dynamic "Pending" orders count
                        icon: Icons.pending,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    // Picked-up Box with dynamic count from orderHistory
                    SizedBox(
                      width: constraints.maxWidth,
                      child: DashboardBox(
                        title: 'Picked-up',
                        count: pickedUpCount,  // Dynamic "Picked-up" count from orderHistory
                        icon: Icons.local_shipping,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                );
              }

              return Wrap(
                spacing: defaultPadding,
                runSpacing: defaultPadding,
                children: [
                  SizedBox(
                    width: boxWidth,
                    child: DashboardBox(
                      title: 'Orders',
                      count: totalOrdersCount,  // Dynamic total orders count
                      icon: Icons.shopping_cart,
                      color: secondaryColor,
                    ),
                  ),
                  SizedBox(
                    width: boxWidth,
                    child: DashboardBox(
                      title: 'Done',
                      count: doneCount,  // Dynamic "Done" orders count
                      icon: Icons.check_circle,
                      color: secondaryColor,
                    ),
                  ),
                  SizedBox(
                    width: boxWidth,
                    child: DashboardBox(
                      title: 'Pending',
                      count: pendingCount,  // Dynamic "Pending" orders count
                      icon: Icons.pending,
                      color: secondaryColor,
                    ),
                  ),
                  SizedBox(
                    width: boxWidth,
                    child: DashboardBox(
                      title: 'Picked-up',
                      count: pickedUpCount,  // Dynamic "Picked-up" count from orderHistory
                      icon: Icons.local_shipping,
                      color: secondaryColor,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: defaultPadding * 1.5),
          const Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: RecentOrders(),
                ),
                SizedBox(height: defaultPadding),
                SizedBox(
                  height: 300,
                  child: TopFoods(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// MobileDashboard - Similar to TabletDashboard, but adapted for mobile screen size
class MobileDashboard extends StatelessWidget {
  final int totalOrdersCount;
  final int doneCount;
  final int pendingCount;
  final int pickedUpCount;

  const MobileDashboard({super.key, required this.totalOrdersCount, required this.doneCount, required this.pendingCount, required this.pickedUpCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: defaultPadding,
              runSpacing: defaultPadding,
              children: [
                // Orders Box with dynamic count
                SizedBox(
                  width: 160,
                  child: DashboardBox(
                    title: 'Orders',
                    count: totalOrdersCount,  // Dynamic total orders count
                    icon: Icons.shopping_cart,
                    color: secondaryColor,
                  ),
                ),
                // Done Box with dynamic count
                SizedBox(
                  width: 160,
                  child: DashboardBox(
                    title: 'Done',
                    count: doneCount,  // Dynamic "Done" orders count
                    icon: Icons.check_circle,
                    color: secondaryColor,
                  ),
                ),
                // Pending Box with dynamic count
                SizedBox(
                  width: 160,
                  child: DashboardBox(
                    title: 'Pending',
                    count: pendingCount,  // Dynamic "Pending" orders count
                    icon: Icons.pending,
                    color: secondaryColor,
                  ),
                ),
                // Picked-up Box with dynamic count from orderHistory
                SizedBox(
                  width: 160,
                  child: DashboardBox(
                    title: 'Picked-up',
                    count: pickedUpCount,  // Dynamic "Picked-up" count from orderHistory
                    icon: Icons.local_shipping,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding * 1.5),
            const RecentOrders(),
            const SizedBox(height: defaultPadding),
            const SizedBox(
              height: 300,
              child: TopFoods(),
            ),
          ],
        ),
      ),
    );
  }
}
