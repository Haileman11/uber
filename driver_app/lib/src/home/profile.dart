import 'package:authentication/authentication_controller.dart';
import 'package:authentication/view/login.dart';
import 'package:common/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
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
              Text("Driver man", style: Theme.of(context).textTheme.headline6),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "+251 911909090",
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
