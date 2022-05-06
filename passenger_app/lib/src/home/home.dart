import 'package:common/ui/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passenger_app/src/booked-ride/booked_ride.dart';
import 'package:passenger_app/src/booked-ride/ui/booked_ride_view.dart';
import 'package:passenger_app/src/complete-ride/complete_ride_details_view.dart';
import 'package:passenger_app/src/home/go.dart';
import 'package:common/ui/keep_alive.dart';
import 'package:passenger_app/src/home/profile.dart';
import 'package:passenger_app/src/map/map_controller.dart';
import 'package:passenger_app/src/places/place_list_view.dart';
import 'package:passenger_app/src/services/top_level_providers.dart';

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
    ref.listen<Map?>(ongoingRideJsonProvider, (previous, current) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => BookedRideView()));
    });
    ref.listen<Map?>(completeRideJsonProvider, (previous, current) {
      BookedRide completeRide = BookedRide.fromJson(current);
      showSnackBar(
          context,
          "Your ride is on the way. License plate is ${completeRide.licensePlate}",
          false);
      // Navigator.of(context).push(MaterialPageRoute(
      //     builder: (_) => CompleteRideDetailsView(completeRide)));
    });
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
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
          BottomNavigationBarItem(icon: Icon(Icons.location_pin), label: "Go"),
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
