import 'package:common/dio_client.dart';
import 'package:common/ui/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:passenger_app/src/booking-request/booking_request_controller.dart';
import 'package:passenger_app/src/booking-request/ui/booking_request_view.dart';
import 'package:passenger_app/src/booking-request/ui/place_picker.dart';
import 'package:passenger_app/src/home/home_controller.dart';
import 'package:passenger_app/src/map/map_controller.dart';
import 'package:passenger_app/src/map/map_service.dart';

import 'package:passenger_app/src/map/map_view.dart';
import 'package:passenger_app/src/services/location_service.dart';
import 'package:uuid/uuid.dart';

import '../services/place_service.dart';
import 'address_search.dart';

class GoTab extends StatefulWidget {
  final Place? origin;

  const GoTab({Key? key, this.origin}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<GoTab> {
  int selectedIndex = 0;
  Place? origin;
  List<Place> destinations = [];

  @override
  void initState() {
    super.initState();
    origin = widget.origin;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);

    return Scaffold(
      // bottomSheet: setupLocation(context),
      body: Stack(
        children: <Widget>[
          Consumer(builder: (context, ref, child) {
            final locationController = ref.watch(locationProvider);
            final homeController = ref.watch(homeProvider);
            if (locationController.serviceEnabled == null) {
              return loadingIndicator;
            } else if (locationController.serviceEnabled!) {
              return CustomScrollView(
                  scrollBehavior: const ScrollBehavior()
                      .copyWith(physics: const BouncingScrollPhysics()),
                  slivers: [
                    // SliverAppBar(
                    //   expandedHeight: MediaQuery.of(context).size.height * 0.6,
                    //   flexibleSpace: FlexibleSpaceBar(
                    //     background: MapView(
                    //       myLocation: locationController.myLocation,
                    //     ),
                    //   ),
                    // ),
                    SliverToBoxAdapter(
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        child: MapView(
                            myLocation: locationController.myLocation,
                            setController: (GoogleMapController controller) {
                              homeController.controller = controller;
                            },
                            polylines: homeController.polylines,
                            markers: homeController.markers),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                          // constraints: BoxConstraints(
                          //     maxHeight:
                          //         MediaQuery.of(context).size.height * 0.6),
                          child: homeController.tripRoute != null
                              ? selectRide(context)
                              : setupLocation(context)),
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
        ],
      ),
    );
  }

  Widget setupLocation(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final homeController = ref.watch(homeProvider);
      return Container(
        padding: const EdgeInsets.all(8.0),
        // constraints:
        //     BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Select location",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (origin != null &&
                            destinations.isNotEmpty &&
                            !homeController.isLoading)
                        ? () async {
                            await homeController.calculateDistance(
                                origin!.location,
                                destinations.removeLast().location,
                                waypoints: destinations
                                    .map((e) => e.location)
                                    .toList());
                          }
                        : null,
                    child: (homeController.isLoading)
                        ? CircularProgressIndicator.adaptive()
                        : const Text("Next"),
                  )
                ],
              ),
              Card(
                child: ListTile(
                  dense: true,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 8,
                    ),
                  ),
                  horizontalTitleGap: 4,
                  title: Text("From",
                      style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text(
                      origin != null
                          ? origin!.formatted_address
                          : "Enter location",
                      style: Theme.of(context).textTheme.bodyText1),
                  onTap: () async {
                    // should show search screen here
                    final sessionToken = Uuid().v4();
                    final result = await showSearch(
                      context: context,
                      query: origin != null ? origin!.formatted_address : null,
                      delegate: AddressSearch(sessionToken, context),
                    );
                    // This will change the text displayed in the TextField
                    if (result != null) {
                      setState(() {
                        origin = result;
                      });
                    }
                  },
                ),
              ),
              if (destinations.isNotEmpty)
                ReorderableListView.builder(
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex = newIndex - 1;
                      }
                      final element = destinations.removeAt(oldIndex);
                      destinations.insert(newIndex, element);
                    });
                  },
                  padding: EdgeInsets.all(0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: destinations.length,
                  itemBuilder: (context, index) => locationWidget(
                      index + 1 < destinations.length ? "Stop" : "To",
                      place: destinations[index]),
                ),
              destinations.isEmpty
                  ? locationWidget("To")
                  : CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      child: IconButton(
                        icon: const Icon(
                          Icons.add,
                        ),
                        onPressed: () async {
                          Place? result = await searchHandler();
                          if (result != null) {
                            setState(() {
                              destinations.add(result);
                            });
                          }
                        },
                      ),
                    ),
            ],
          ),
        ),
      );
    });
  }

  Widget locationWidget(String title, {Place? place}) {
    return Card(
      key: ValueKey(place),
      child: ListTile(
        dense: true,
        trailing: place != null
            ? IconButton(
                onPressed: () {
                  setState(() {
                    destinations.remove(place);
                  });
                },
                icon: const Icon(
                  Icons.close,
                ),
              )
            : null,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: title == "To" ? Colors.red : Colors.yellow,
            radius: 8,
          ),
        ),
        horizontalTitleGap: 4,
        title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        subtitle: Text(
            place != null ? place.formatted_address : "Enter location",
            style: Theme.of(context).textTheme.bodyText1!),
        onTap: () async {
          Place? result = await searchHandler();
          if (result != null) {
            setState(() {
              place != null ? place = result : destinations.add(result);
            });
          }
        },
      ),
    );
  }

  // Future<Place?> placePickerHandler(
  //   MapController mapController,
  // ) async {
  //   Place? selectedLocation = await Navigator.of(context)
  //       .push(MaterialPageRoute(builder: (_) => PlacePicker()));
  //   return selectedLocation;
  // }
  Widget selectRide(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final homeController = ref.watch(homeProvider);
      return Container(
        padding: const EdgeInsets.all(8.0),
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  Text(
                    "Select Ride",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                      onPressed: () => homeController.cancelRoute(),
                      icon: Icon(Icons.cancel))
                ],
              ),
              SizedBox(
                height: 150.0,
                child: ListView.builder(
                  itemCount: homeController.price!.length,
                  padding: const EdgeInsets.all(16.0),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) {
                    var package = homeController.price![index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ChoiceChip(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        )),
                        avatarBorder: RoundedRectangleBorder(
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.all(
                            Radius.circular(4),
                          ),
                        ),
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        label: Column(
                          children: [
                            SizedBox(
                                width: 100,
                                child: Image.asset(
                                  'assets/images/${package.packageName}.png',
                                  height: 50,
                                  fit: BoxFit.cover,
                                )),
                            Text(package.packageName),
                            Text("${package.price.toStringAsFixed(0)} ETB"),
                          ],
                        ),
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              selectedIndex = index;
                            }
                            print(selectedIndex);
                          });
                        },
                        selected: selectedIndex == index,
                      ),
                    );
                  },
                ),
              ),
              // Text(
              //   "${bookingRequestController.bookingRequest!.distance.toStringAsFixed(0)} meters",
              //   style: Theme.of(context).textTheme.headline6,
              // ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: (!homeController.isLoading)
                      ? () {
                          homeController.bookTrip(
                              homeController.polylines.keys.first.value,
                              homeController.price![selectedIndex].packageName);

                          // showSnackBar(
                          //     context, "Successfully requested ride.", false);
                        }
                      : null,
                  child: homeController.isLoading
                      ? CircularProgressIndicator.adaptive()
                      : const Text("Request ride"),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<Place?> searchHandler() async {
    final sessionToken = Uuid().v4();
    final result = await showSearch(
      context: context,
      delegate: AddressSearch(sessionToken, context),
    );
    return result;
  }
}
