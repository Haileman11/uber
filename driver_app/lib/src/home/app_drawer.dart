import 'package:common/authentication/authentication_controller.dart';
import 'package:common/authentication/view/login.dart';
import 'package:common/settings/settings_view.dart';
import 'package:driver_app/src/booked-ride/ui/earnings_view.dart';
import 'package:driver_app/src/profile/profile_view.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:driver_app/src/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Consumer(builder: (context, ref, child) {
          final profile = ref.watch(profileProvider).profile;
          return Column(
            children: <Widget>[
              Container(
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
                padding:
                    const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 30.0,
                      backgroundImage:
                          NetworkImage("https://picsum.photos/200/300"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${profile!.firstName} ${profile.lastName}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(color: Colors.white)),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                              PhoneNumber(
                                phoneNumber: profile.userName,
                              ).toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ListTile(
                  onTap: () =>
                      Navigator.of(context).pushNamed(ProfileView.routeName),
                  leading: Icon(Icons.account_circle),
                  title: Text('Profile'),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ListTile(
                  onTap: () =>
                      Navigator.of(context).pushNamed(EarningView.routeName),
                  leading: Icon(Icons.monetization_on),
                  title: Text('Earnings'),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ListTile(
                  onTap: () =>
                      Navigator.of(context).pushNamed(SettingsView.routeName),
                  leading: Icon(Icons.account_balance_wallet),
                  title: Text('Balance'),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ListTile(
                  onTap: () =>
                      Navigator.of(context).pushNamed(SettingsView.routeName),
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
              Consumer(builder: (context, ref, child) {
                var isLoggedIn = ref.watch(authenticationProvider).isLoggedIn;
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: ListTile(
                    onTap: !isLoggedIn
                        ? () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => Login()))
                        : () async {
                            // if (await showLogoutConfirmDialog(context)) {
                            ref.watch(authenticationProvider).logout();
                          },
                    leading: Icon(Icons.logout),
                    title: Text(!isLoggedIn ? 'Log in' : 'Log out'),
                  ),
                );
              }),
            ],
          );
        }),
      ),
    );
  }
}
