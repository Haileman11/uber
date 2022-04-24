import 'package:common/map/map_controller.dart';
import 'package:common/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passenger_app/src/home/go.dart';
import 'package:common/ui/keep_alive.dart';
import 'package:passenger_app/src/home/profile.dart';
import 'package:passenger_app/src/places/place_list_view.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  int currentTab = 0;
  PageController pageController = PageController();
  var gotTab = GoTab();
  var placesTab = PlaceListView();
  var profileTab = Profile();
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: ref.watch(mapProvider).destinations.isNotEmpty
          ? null
          : BottomNavigationBar(
              backgroundColor: _theme.bottomAppBarColor,
              currentIndex: currentTab,
              onTap: (index) {
                setState(() {
                  currentTab = index;
                });
                pageController.jumpToPage(index);
              },
              showSelectedLabels: true,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.location_pin), label: "Go"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.bookmarks), label: "My Places"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle), label: "Profile"),
              ],
            ),
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          setState(() {
            currentTab = page;
          });
        },
        children: <Widget>[KeepAlivePage(child: gotTab), placesTab, profileTab],
      ),
    );
  }
}
