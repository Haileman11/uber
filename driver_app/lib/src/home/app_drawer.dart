import 'package:common/authentication/authentication_controller.dart';
import 'package:common/authentication/view/login.dart';
import 'package:common/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List _drawerMenu = [
      {
        "icon": Icons.login,
        "text": "Log in",
        "route": Login(),
      },
      // {
      //   "icon": Icons.restore,
      //   "text": "My rides",
      //   "route": MyRidesRoute,
      // },
      // {
      //   "icon": Icons.local_activity,
      //   "text": "Promotions",
      //   "route": PromotionRoute
      // },
      // {
      //   "icon": Icons.star_border,
      //   "text": "My favourites",
      //   "route": FavoritesRoute
      // },
      // {
      //   "icon": Icons.credit_card,
      //   "text": "My payments",
      //   "route": PaymentRoute,
      // },
      // {
      //   "icon": Icons.notifications,
      //   "text": "Notification",
      // },
      // {
      //   "icon": Icons.chat,
      //   "text": "Support",
      //   "route": ChatRiderRoute,
      // }
    ];

    return Drawer(
      child: Consumer(builder: (context, watch, child) {
        // SharedPrefs sharedPrefs = watch(sharedPreferencesProvider);
        return Column(
          children: <Widget>[
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
            //   child: CircleAvatar(
            //     radius: 50.0,
            //     backgroundColor: Colors.transparent,
            //     backgroundImage: student != null &&
            //             student.profilePicture != null &&
            //             student.profilePicture != ""
            //         ? CachedNetworkImageProvider(
            //             student.profilePicture,
            //           )
            //         : const AssetImage("assets/images/user.png"),
            //   ),
            // ),
            // if (sharedPrefs.isLoggedIn && student != null)
            //   Align(
            //     alignment: Alignment.bottomCenter,
            //     child: Text(
            //       "${student.firstName} ${student.lastName}",
            //       style: Theme.of(context).textTheme.headline6,
            //     ),
            //   ),
            // if (sharedPrefs.isLoggedIn)
            //   Align(
            //     alignment: Alignment.bottomCenter,
            //     child: MaterialButton(
            //       onPressed: () {
            //         Navigator.of(context).push(MaterialPageRoute(
            //             builder: (BuildContext context) => ProfileScreen()));
            //       },
            //       child: Text(
            //           AppLocalizations.of(context).translate('label_profile')),
            //     ),
            //   ),
            // if (sharedPrefs.isLoggedIn)
            //   Align(
            //     alignment: Alignment.bottomCenter,
            //     child: MaterialButton(
            //       onPressed: () {
            //         Navigator.of(context).push(MaterialPageRoute(
            //             builder: (BuildContext context) => FavouriteScreen()));
            //       },
            //       child: Text(AppLocalizations.of(context)
            //           .translate('label_favorites')),
            //     ),
            //   ),
            // if (sharedPrefs.isLoggedIn)
            //   Align(
            //     alignment: Alignment.bottomCenter,
            //     child: MaterialButton(
            //       onPressed: () {
            //         Navigator.of(context).push(MaterialPageRoute(
            //             builder: (BuildContext context) =>
            //                 BankAccountsScreen()));
            //       },
            //       child: Text(AppLocalizations.of(context)
            //           .translate('label_bank_accounts')),
            //     ),
            //   ),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: MaterialButton(
            //     onPressed: () {
            //       Navigator.of(context).push(MaterialPageRoute(
            //           builder: (BuildContext context) => SettingsScreen()));
            //     },
            //     child: Text(
            //         AppLocalizations.of(context).translate('label_settings')),
            //   ),
            // ),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: MaterialButton(
            //     onPressed: !sharedPrefs.isLoggedIn
            //         ? () {
            //             Navigator.of(context).push(MaterialPageRoute(
            //                 builder: (BuildContext context) =>
            //                     const SignIn(from: 'Homepage')));
            //           }
            //         : () async {
            //             if (await showLogoutConfirmDialog(context)) {
            //               sharedPrefs.logOut();
            //             }
            //           },
            //     child: Text(
            //       AppLocalizations.of(context).translate(!sharedPrefs.isLoggedIn
            //           ? 'label_sign_in'
            //           : 'label_log_out'),
            //     ),
            //   ),
            // )
            const SizedBox(
              height: 20,
            ),
            CircleAvatar(
              radius: 50.0,
              backgroundImage: NetworkImage("https://picsum.photos/200/300"),
            ),
            SizedBox(
              height: 7.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Passenger man",
                    style: Theme.of(context).textTheme.headline6),
              ],
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: MaterialButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(SettingsView.routeName),
                child: Text('Settings'),
              ),
            ),

            Consumer(builder: (context, ref, child) {
              var isLoggedIn = ref.watch(authenticationProvider).isLoggedIn;
              return Align(
                alignment: Alignment.bottomCenter,
                child: MaterialButton(
                  onPressed: !isLoggedIn
                      ? () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => Login()))
                      : () async {
                          // if (await showLogoutConfirmDialog(context)) {
                          ref.watch(authenticationProvider).logout();
                        },
                  child: Text(!isLoggedIn ? 'Log in' : 'Log out'),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
