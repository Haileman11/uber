import 'package:common/ui/keep_alive.dart';
import 'package:driver_app/src/booked-ride/booked_ride_controller.dart';
import 'package:driver_app/src/booked-ride/ui/booked_ride_list_view.dart';
import 'package:driver_app/src/booking-request/booking_request_view.dart';
import 'package:driver_app/src/booked-ride/ui/ride_summary_view.dart';
import 'package:driver_app/src/home/go.dart';
import 'package:driver_app/src/map/map_controller.dart';
import 'package:driver_app/src/profile/profile_view.dart';
import 'package:driver_app/src/services/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  int currentTab = 0;
  PageController pageController = PageController();
  var gotTab = GoTab();
  var placesTab = CompleteRideListView();
  var profileTab = ProfileView();
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    ref.listen<Map?>(bookingRequestJsonProvider, (previous, current) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => BookingRequestView()));
    });
    ref.listen<BookedRideController>(bookedRideProvider, (previous, current) {
      if (current.completeRide != null) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => RideSummaryView()));
      }
    });

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
                    icon: Icon(Icons.drive_eta), label: "Recent Trips"),
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
