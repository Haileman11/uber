import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationService with ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(MaterialPageRoute routeName,
      {bool replace = false}) {
    return replace
        ? navigatorKey.currentState!.pushReplacement(routeName)
        : navigatorKey.currentState!.push(routeName);
  }

  void goBackTo(
    String routeName,
  ) {
    return navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  goBack() {
    return navigatorKey.currentState!.pop();
  }
}

final navigationProvider = ChangeNotifierProvider((ref) => NavigationService());
