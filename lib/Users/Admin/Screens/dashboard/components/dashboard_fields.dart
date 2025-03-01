// import 'package:flutter/material.dart';
// import '../../../Admin Constants/Admin_Constants.dart';
// import '../../../Admin Constants/Admin_Responsive.dart';
// import '../../../models/dashboard_model.dart';
// import 'dashboard_info_card.dart';

// class MyFiles extends StatelessWidget {
//   const MyFiles({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//     return Column(
//       children: [
//         const SizedBox(height: defaultPadding),
//         Responsive(
//           mobile: FileInfoCardGridView(
//             crossAxisCount: size.width < 650 ? 2 : 4,
//             childAspectRatio: size.width < 650 && size.width > 350 ? 1.3 : 1,
//           ),
//           tablet: const FileInfoCardGridView(),
//           desktop: FileInfoCardGridView(
//             childAspectRatio: size.width < 1400 ? 1.1 : 1.4,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class FileInfoCardGridView extends StatelessWidget {
//   const FileInfoCardGridView({
//     super.key,
//     this.crossAxisCount = 4,
//     this.childAspectRatio = 1,
//   });

//   final int crossAxisCount;
//   final double childAspectRatio;

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemCount: demoMyFiles.length,
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxisCount,
//         crossAxisSpacing: defaultPadding,
//         mainAxisSpacing: defaultPadding,
//         childAspectRatio: childAspectRatio,
//       ),
//       itemBuilder: (context, index) => FileInfoCard(info: demoMyFiles[index]),
//     );
//   }
// }
