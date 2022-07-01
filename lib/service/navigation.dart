import 'package:flutter/material.dart';
import '../pages/route.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName);
  }

  Future<dynamic> navigateToHome(bool authenticated) {
    return navigatorKey.currentState!.pushReplacementNamed(RouteName.routeNameHome, arguments: authenticated);
  }

}