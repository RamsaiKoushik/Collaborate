
// import 'package:flutter/material.dart';

// Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // use this button to open the multi-select dialog
//                       ElevatedButton(
//                           onPressed: _showMultiSelect,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white
//                                 .withOpacity(0.3), // Set the background color
//                             foregroundColor: Colors.white, // Set the text color
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(
//                                   30.0), // Set border radius
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 10, horizontal: 10), // Set padding
//                             textStyle: const TextStyle(fontSize: 16),
//                           ),
//                           child: const Text('choose')
//                           // const Text('Which areas would you like to explore'),
//                           ),

//                       Wrap(
//                         children: _learnSkills
//                             .map((e) => Padding(
//                                   padding: const EdgeInsets.all(4.0),
//                                   child: Chip(
//                                     label: Text(e),
//                                     backgroundColor: checkBoxColor,
//                                   ),
//                                 ))
//                             .toList(),
//                       )
//                     ]),
//               ),