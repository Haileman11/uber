import 'package:common/authentication/view/login.dart';
import 'package:driver_app/src/booked-ride/booked_ride_controller.dart';
import 'package:driver_app/src/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/shared_preferences_service.dart';
import 'package:driver_app/src/services/top_level_providers.dart';
import 'home/home.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // "ref" can be used in all life-cycles of a StatefulWidget.
  }

  @override
  Widget build(BuildContext context) {
    // We can also use "ref" to listen to a provider inside the build method
    return FutureBuilder(
        future: ref.read(sharedPreferencesInstance.future),
        builder: ((context, snapshot) {
          final authStateChanges = ref.watch(authStateChangesProvider);
          return authStateChanges.when(
              data: (user) => _data(context, user),
              loading: () => Scaffold(
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 52, 0, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Uber ET',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3!
                                    .copyWith()),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: CircularProgressIndicator.adaptive(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
              error: (_, stackTrace) => Scaffold(
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 52, 0, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Uber ET',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3!
                                    .copyWith()),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                children: [
                                  Text("Error loading app"),
                                  Text(stackTrace.toString()),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ));
        }));
  }

  _data(BuildContext context, bool? isLoggedIn) {
    if (isLoggedIn == null || isLoggedIn == false) {
      return Builder(builder: (context) {
        return const Login();
      });
    }
    return FutureBuilder(
        future: Future.wait([
          ref.read(profileProvider).getUserProfile(),
          ref.read(bookedRideProvider).getBookedRides()
        ]),
        builder: (context, snapshot) {
          return const Home();
        });
  }
}
