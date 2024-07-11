import 'package:crops/core/models/user.dart';
import 'package:crops/features/crops/data/model/crop.dart';
import 'package:crops/features/crops/prsentaion/screens/type_details.dart';
import 'package:crops/features/profile/presentation/screens/user_profile.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String userProfile = '/userProfile';
  static const String cropDetails = '/cropDetails';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case userProfile:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          final Users user = args['user'] as Users;
          final String userID = args['userID'] as String;
          return MaterialPageRoute(
            builder: (_) => UserProfile(user: user, userID: userID),
          );
        }
        return _errorRoute();
      case cropDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          final crop = args['crop'] as Crops;
          return MaterialPageRoute(
            builder: (_) => TypesDetails(crop: crop),
          );
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('Error: Route not found'),
        ),
      ),
    );
  }
}
