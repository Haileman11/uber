// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:flutter_riverpod/src/provider.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// import 'package:tutor_student_app/config/app_localizations.dart';
// import 'package:tutor_student_app/models/review.dart';
// import 'package:tutor_student_app/ui/auth/sign_in.dart';
// import 'package:tutor_student_app/utils/validation.dart';

// showErrorDialog(BuildContext context, DioError e, {Dio dio}) {
//   var message = e.response == null
//       ? e.error is SocketException
//           ? e.message
//           : e.error.message
//       : e.response.data['message'];
//   return showDialog(
//       context: context,
//       useRootNavigator: false,
//       builder: (context) {
//         return AlertDialog(
//           content: Text(message),
//           actions: [
//             if (dio != null)
//               ElevatedButton(
//                 onPressed: () async {
//                   var response = await dio.fetch(e.requestOptions);
//                   Navigator.of(context).pop(response);
//                 },
//                 child: Text(
//                   AppLocalizations.of(context)
//                       .translate(e.error is SocketException
//                           ? "label_retry"
//                           : e.response.statusCode == 401
//                               ? 'label_sign_in'
//                               : ''),
//                 ),
//               ),
//             TextButton(
//                 onPressed: () => e.error is! SocketException
//                     ? Navigator.of(context).pop()
//                     : SystemNavigator.pop(),
//                 child: Text(
//                     AppLocalizations.of(context).translate('label_close'))),
//           ],
//         );
//       });
// }

// Future<bool> showConfirmDialog(context) {
//   return showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text(
//             AppLocalizations.of(context).translate('label_confirm_delete')),
//         content: Text(
//             AppLocalizations.of(context).translate('message_confirm_delete')),
//         actions: <Widget>[
//           ElevatedButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child:
//                   Text(AppLocalizations.of(context).translate('label_delete'))),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: Text(AppLocalizations.of(context).translate('label_back')),
//           ),
//         ],
//       );
//     },
//   );
// }

// Future<bool> showLogoutConfirmDialog(context) {
//   return showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text(AppLocalizations.of(context).translate('label_log_out')),
//         content: Text(AppLocalizations.of(context)
//             .translate('label_logout_confirmation')),
//         actions: <Widget>[
//           ElevatedButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: Text(
//                   AppLocalizations.of(context).translate('label_log_out'))),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: Text(AppLocalizations.of(context).translate('label_back')),
//           ),
//         ],
//       );
//     },
//   );
// }
