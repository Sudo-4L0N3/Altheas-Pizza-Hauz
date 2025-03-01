// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class CloudStorageInfo {
//   final IconData? icon;
//   final String? title, totalStorage;
//   final int? numOfFiles, percentage;
//   final Color? color;

//   CloudStorageInfo({
//     this.icon,
//     this.title,
//     this.totalStorage,
//     this.numOfFiles,
//     this.percentage,
//     this.color,
//   });
// }

// class PickedUpOrders extends StatefulWidget {
//   @override
//   _PickedUpOrdersState createState() => _PickedUpOrdersState();
// }

// class _PickedUpOrdersState extends State<PickedUpOrders> {
//   int pickedUpCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     _countPickedUpOrders();
//   }

//   void _countPickedUpOrders() async {
//     try {
//       // Query Firestore to get the count of 'Picked-up' orders
//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('orderHistory')
//           .where('status', isEqualTo: 'Picked-up')
//           .get();

//       // Check if documents are retrieved
//       print('Total Picked-up Orders: ${snapshot.docs.length}');

//       if (snapshot.docs.isEmpty) {
//         print('No documents with status "Picked-up" were found.');
//       } else {
//         snapshot.docs.forEach((doc) {
//           print('Document data: ${doc.data()}');
//         });
//       }

//       setState(() {
//         pickedUpCount = snapshot.docs.length;

//         // Update the Picked-Up card in the demoMyFiles list with the new total
//         demoMyFiles[1] = CloudStorageInfo(
//           title: "Picked-Up",
//           numOfFiles: pickedUpCount,
//           icon: Icons.handshake,
//           totalStorage: pickedUpCount.toString(),
//           color: Colors.blueAccent,
//           percentage: 35,
//         );
//       });
//     } catch (error) {
//       print('Error fetching picked-up orders: $error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: demoMyFiles
//           .map((fileInfo) => CloudStorageInfoCard(
//                 title: fileInfo.title,
//                 numOfFiles: fileInfo.numOfFiles,
//                 totalStorage: fileInfo.totalStorage,
//                 icon: fileInfo.icon,
//                 color: fileInfo.color,
//                 percentage: fileInfo.percentage,
//               ))
//           .toList(),
//     );
//   }
// }

// class CloudStorageInfoCard extends StatelessWidget {
//   final String? title;
//   final int? numOfFiles;
//   final String? totalStorage;
//   final IconData? icon;
//   final Color? color;
//   final int? percentage;

//   const CloudStorageInfoCard({
//     Key? key,
//     this.title,
//     this.numOfFiles,
//     this.totalStorage,
//     this.icon,
//     this.color,
//     this.percentage,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: ListTile(
//         leading: Icon(icon, color: color),
//         title: Text(title ?? ''),
//         subtitle: Text('$numOfFiles orders'),
//         trailing: Text('$totalStorage Picked-up total'),
//       ),
//     );
//   }
// }

// List demoMyFiles = [
//   CloudStorageInfo(
//     title: "Order",
//     numOfFiles: 125,
//     icon: Icons.shopping_cart_checkout,
//     totalStorage: "20",
//     color: Colors.purpleAccent,
//     percentage: 35,
//   ),
//   CloudStorageInfo(
//     title: "Picked-Up",
//     numOfFiles: 0, // This will be updated dynamically
//     icon: Icons.handshake,
//     totalStorage: "0", // This will be updated dynamically
//     color: Colors.blueAccent,
//     percentage: 35,
//   ),
//   CloudStorageInfo(
//     title: "Done",
//     numOfFiles: 1328,
//     icon: Icons.pending,
//     totalStorage: "53",
//     color: Colors.greenAccent,
//     percentage: 10,
//   ),
//   CloudStorageInfo(
//     title: "Pending",
//     numOfFiles: 5328,
//     icon: Icons.cancel_outlined,
//     totalStorage: "10",
//     color: Colors.orangeAccent,
//     percentage: 78,
//   ),
// ];
