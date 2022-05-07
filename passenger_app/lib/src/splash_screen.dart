import 'package:common/authentication/view/login.dart';
import 'package:common/authentication/view/unauth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:common/shared_preferences_service.dart';
import 'package:passenger_app/src/home/home.dart';
import 'package:passenger_app/src/services/top_level_providers.dart';
import 'home/go.dart';
import 'profile/profile_controller.dart';

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
              error: (_, __) => Scaffold(
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
                              child: Text("Error loading app"),
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
        future: ref.read(profileProvider).getUserProfile(),
        builder: (context, snapshot) {
          return const Home();
        });
  }
}
