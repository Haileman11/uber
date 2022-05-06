import 'package:common/ui/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:passenger_app/src/booked-ride/booked_ride_controller.dart';
import 'package:passenger_app/src/booking-request/booking_request_controller.dart';
import 'package:passenger_app/src/booking-request/ui/booking_request_view.dart';
import 'package:passenger_app/src/booking-request/ui/place_picker.dart';
import 'package:passenger_app/src/map/map_controller.dart';
import 'package:passenger_app/src/map/map_service.dart';

import 'package:passenger_app/src/map/map_view.dart';
import 'package:passenger_app/src/services/location_service.dart';
import 'package:tuple/tuple.dart';
import 'search.dart';

class GoTab extends ConsumerStatefulWidget {
  const GoTab({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<GoTab> {
  String? currentAddress;

  var pageController = PageController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      myLocation = await ref.read(locationProvider).getMyLocation();
    });
  }

  LatLng? myLocation;

  final _destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final locationController = ref.watch(locationProvider);
    final mapController = ref.watch(mapProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Builder(builder: (context) {
              if (locationController.serviceEnabled == null) {
                return loadingIndicator;
              } else if (locationController.serviceEnabled!) {
                return CustomScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Container(
                          constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height),
                          child: MapView(
                            myLocation: locationController.myLocation,
                          ),
                        ),
                      ),
                    ]);
              } else {
                return Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Location is disabled."),
                      TextButton(
                        onPressed: () async {
                          if (await Geolocator.openAppSettings()) {
                            if (await Geolocator.openLocationSettings()) {
                              locationController.getMyLocation();
                            }
                          }
                        },
                        child: const Text("Request permission"),
                      ),
                      TextButton(
                        onPressed: () async {
                          locationController.getMyLocation();
                        },
                        child: const Text("Refresh"),
                      ),
                    ],
                  ),
                );
              }
            }),

            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Card(
                      child: AppBar(
                        backgroundColor: _theme.backgroundColor,
                        elevation: 0.0,
                        // leading: IconButton(
                        //   onPressed: () {
                        //     _scaffoldKey.currentState!.openDrawer();
                        //   },
                        //   icon: const Icon(
                        //     Icons.menu,
                        //   ),
                        // ),
                        title: InkWell(
                          onTap: () async {
                            LatLng? selectedLocation;
                            await showSearch(
                                context: context, delegate: DataSearch());
                            if (selectedLocation != null) {
                              // setState(() {
                              //   mapController.destinations.add( selectedLocation);
                              // });
                            }
                          },
                          child: TextField(
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: "Where to?",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                            controller: _destinationController,
                          ),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () => placePickerHandler(
                                mapController, locationController),
                            icon: const Icon(
                              Icons.location_on_sharp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChoiceChip(
                            label: const Text("Work"),
                            onSelected: (val) {},
                            selected: false,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChoiceChip(
                            label: const Text("Home"),
                            onSelected: (val) {},
                            selected: false,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChoiceChip(
                            label: const Text("Gym"),
                            onSelected: (val) {},
                            selected: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // showLocationBottomSheet(mapController, context)
          ],
        ),
      ),
    );
  }

  void placePickerHandler(
      MapController mapController, LocationService locationController) async {
    Tuple2<String, LatLng>? selectedLocation = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => PlacePicker()));
    if (selectedLocation != null) {
      ref.read(bookingRequestProvider).addDestination(
            selectedLocation,
          );

      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => BookingRequestView()));
    }
  }
}
