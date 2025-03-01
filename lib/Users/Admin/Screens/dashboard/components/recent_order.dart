// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../Admin Constants/Admin_Constants.dart';
// import '../../../models/recent_order_model.dart';

// class RecentOrders extends StatelessWidget {
//   const RecentOrders({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(defaultPadding),
//       decoration: const BoxDecoration(
//         color: secondaryColor,
//         borderRadius: BorderRadius.all(Radius.circular(10)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Recent Orders",
//             style: TextStyle(color: Colors.white),
//           ),
//           SizedBox(
//             width: double.infinity,
//             child: StreamBuilder(
//               stream: FirebaseFirestore.instance.collection('Order').snapshots(),
//               builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 // Convert Firestore documents to a list of RecentOrder
//                 List<RecentOrder> recentOrders = snapshot.data!.docs
//                     .map((doc) => RecentOrder.fromFirestore(doc))
//                     .toList();

//                 return DataTable(
//                   columnSpacing: defaultPadding,
//                   columns: const [
//                     DataColumn(
//                       label: Text("Food Name", style: TextStyle(color: Colors.white)),
//                     ),
//                     DataColumn(
//                       label: Text("Date", style: TextStyle(color: Colors.white)),
//                     ),
//                     DataColumn(
//                       label: Text("Status", style: TextStyle(color: Colors.white)),
//                     ),
//                   ],
//                   rows: List.generate(
//                     recentOrders.length,
//                     (index) => recentOrderDataRow(recentOrders[index]),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// DataRow recentOrderDataRow(RecentOrder orderInfo) {
//   return DataRow(
//     cells: [
//       DataCell(
//         Row(
//           children: [
//             const Icon(
//               Icons.fastfood, // Default icon for now
//               size: 20,
//               color: Colors.white,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
//               child: Text(
//                 orderInfo.foodName ?? "Unknown",
//                 style: const TextStyle(color: Colors.white, fontSize: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//       DataCell(Text(
//         orderInfo.date != null
//             ? "${orderInfo.date!.day}-${orderInfo.date!.month}-${orderInfo.date!.year}"
//             : "Unknown",
//         style: const TextStyle(color: Colors.white, fontSize: 12),
//       )),
//       DataCell(Text(
//         orderInfo.status ?? "Unknown",
//         style: const TextStyle(color: Colors.white, fontSize: 12),
//       )),
//     ],
//   );
// }
