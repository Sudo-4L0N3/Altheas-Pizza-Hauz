// import 'package:flutter/material.dart';
// import '../../../Admin Constants/Admin_Constants.dart';
// import 'rank_info_card.dart';
// import 'food_ranker.dart';

// class RankDetails extends StatelessWidget {
//   const RankDetails({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, int>>(
//       future: FoodRanker().getFoodRankings(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError || !snapshot.hasData) {
//           return const Center(child: Text("Error fetching rankings"));
//         }

//         var foodRankings = snapshot.data!;
//         return Container(
//           padding: const EdgeInsets.all(defaultPadding),
//           decoration: const BoxDecoration(
//             color: secondaryColor,
//             borderRadius: BorderRadius.all(Radius.circular(10)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Top Sales",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: defaultPadding),
//               ...foodRankings.entries.take(5).map((entry) {
//                 int rank = foodRankings.keys.toList().indexOf(entry.key) + 1;
//                 return RankInfoCard(
//                   rankNumber: rank.toString(),
//                   foodName: entry.key,
//                   orderCount: "${entry.value} orders",
//                 );
//               }).toList(),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
