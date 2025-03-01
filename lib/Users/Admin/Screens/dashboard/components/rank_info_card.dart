// import 'package:flutter/material.dart';
// import '../../../Admin Constants/Admin_Constants.dart';

// class RankInfoCard extends StatelessWidget {
//   const RankInfoCard({
//     super.key,
//     required this.foodName,
//     required this.rankNumber,
//     required this.orderCount,
//   });

//   final String foodName, rankNumber, orderCount;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(top: defaultPadding),
//       padding: const EdgeInsets.all(defaultPadding),
//       decoration: BoxDecoration(
//         border: Border.all(width: 2, color: primaryColor.withOpacity(0.15)),
//         borderRadius: const BorderRadius.all(
//           Radius.circular(defaultPadding),
//         ),
//       ),
//       child: Row(
//         children: [
//           // Rank Number Icon
//           Container(
//             height: 30,
//             width: 30,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: primaryColor.withOpacity(0.15),
//             ),
//             child: Text(
//               rankNumber,
//               style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Food Name
//                   Text(
//                     foodName,
//                     style: const TextStyle(color: Colors.white),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Order Count
//           Text(orderCount, style: const TextStyle(color: Colors.white),)
//         ],
//       ),
//     );
//   }
// }
