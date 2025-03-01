// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../../Admin Constants/Admin_Responsive.dart';
// import '../../../controllers/menu_app_controller.dart';


// class Header extends StatelessWidget {
//   const Header({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         if (!Responsive.isDesktop(context))
//           IconButton(
//             icon: const Icon(Icons.menu),
//             onPressed: context.read<MenuAppController>().controlMenu,
//           ),
//         if (!Responsive.isMobile(context))
//           const Text(
//             "Dashboard",
//             style: TextStyle(color: Colors.white, fontSize: 30),
//           ),
//         if (!Responsive.isMobile(context))
//           Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
//         //Expanded(child: SearchField()),
//         //ProfileCard()
//       ],
//     );
//   }
// }

// // class ProfileCard extends StatelessWidget {
// //   const ProfileCard({
// //     Key? key,
// //   }) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       margin: EdgeInsets.only(left: defaultPadding),
// //       padding: EdgeInsets.symmetric(
// //         horizontal: defaultPadding,
// //         vertical: defaultPadding / 2,
// //       ),
// //       decoration: BoxDecoration(
// //         color: secondaryColor,
// //         borderRadius: const BorderRadius.all(Radius.circular(10)),
// //         border: Border.all(color: Colors.white10),
// //       ),
// //       child: Row(
// //         children: [
// //           ClipOval(
// //             child: Image.asset(
// //               "assets/images/Sample-picture.jpg",
// //               height: 38,
              
// //             ),
// //           ),
// //           if (!Responsive.isMobile(context))
// //             Padding(
// //               padding:
// //                   const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
// //               child: Text("Sample Admin"),
// //             ),
// //           Icon(Icons.keyboard_arrow_down),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class SearchField extends StatelessWidget {
// //   const SearchField({
// //     Key? key,
// //   }) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     return TextField(
// //       decoration: InputDecoration(
// //         hintText: "Search",
// //         fillColor: secondaryColor,
// //         filled: true,
// //         border: OutlineInputBorder(
// //           borderSide: BorderSide.none,
// //           borderRadius: const BorderRadius.all(Radius.circular(10)),
// //         ),
// //         suffixIcon: InkWell(
// //           onTap: () {},
// //           child: Container(
// //             padding: EdgeInsets.all(defaultPadding * 0.75),
// //             margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
// //             decoration: BoxDecoration(
// //               color: primaryColor,
// //               borderRadius: const BorderRadius.all(Radius.circular(10)),
// //             ),
// //             child: SvgPicture.asset("assets/icons/Search.svg"),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
