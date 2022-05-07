import 'package:common/authentication/authentication_controller.dart';
import 'package:common/authentication/view/login.dart';
import 'package:common/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_controller.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileView> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<ProfileView> {
  @override
  Widget build(BuildContext context) {
    final profileController = ref.read(profileProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: 16.0,
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
              Text(
                  "${profileController.profile!.firstName} ${profileController.profile!.lastName}",
                  style: Theme.of(context).textTheme.headline6),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "${profileController.profile!.userName}",
              ),
            ],
          ),
          Card(
            child: ListTile(
              trailing:
                  TextButton(child: Text("Change Password"), onPressed: () => {}
                      // Navigator.of(context).push(
                      //     MaterialPageRoute(
                      //         builder: (_) =>
                      //             NewPassword(isForgot: false)))
                      ),
              leading: Text("Password"),
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
      )),
    );
  }
}
