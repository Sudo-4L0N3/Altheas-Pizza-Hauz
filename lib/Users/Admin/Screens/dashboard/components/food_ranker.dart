// import 'package:cloud_firestore/cloud_firestore.dart';

// class FoodRanker {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<Map<String, int>> getFoodRankings() async {
//     QuerySnapshot snapshot = await _firestore.collection('orderHistory').get();

//     Map<String, int> foodCount = {};

//     for (var doc in snapshot.docs) {
//       List items = doc['items'];
//       for (var item in items) {
//         String foodName = item['foodName'];
//         if (foodCount.containsKey(foodName)) {
//           foodCount[foodName] = foodCount[foodName]! + 1;
//         } else {
//           foodCount[foodName] = 1;
//         }
//       }
//     }

//     // Sorting food by count in descending order
//     var sortedFoodCount = Map.fromEntries(
//       foodCount.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value)),
//     );

//     return sortedFoodCount;
//   }
// }
