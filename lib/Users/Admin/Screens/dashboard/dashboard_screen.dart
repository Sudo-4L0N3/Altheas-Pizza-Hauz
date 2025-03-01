// import 'package:flutter/material.dart';
// import '../../Admin Constants/Admin_Constants.dart';
// import '../../Admin Constants/Admin_Responsive.dart';
// import 'components/dashboard_fields.dart';
// import 'components/header.dart';

// import 'components/recent_order.dart';
// import 'components/rank_details.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: SingleChildScrollView(
//         primary: false,
//         padding: const EdgeInsets.all(defaultPadding),
//         child: Column(
//           children: [
//             const Header(),
//             const SizedBox(height: defaultPadding),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   flex: 5,
//                   child: Column(
//                     children: [
//                       const MyFiles(),
//                       const SizedBox(height: defaultPadding),
//                       const RecentOrders(),
//                       if (Responsive.isMobile(context))
//                         const SizedBox(height: defaultPadding),
//                       if (Responsive.isMobile(context)) const RankDetails(),
//                     ],
//                   ),
//                 ),
//                 if (!Responsive.isMobile(context))
//                   const SizedBox(width: defaultPadding),
//                 // On Mobile means if the screen is less than 850 we don't want to show it
//                 if (!Responsive.isMobile(context))
//                   const Expanded(
//                     flex: 2,
//                     child: RankDetails(),
//                   ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
