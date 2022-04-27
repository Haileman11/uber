import 'package:common/ui/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:passenger_app/src/home/place_picker.dart';
import 'package:passenger_app/src/map/map_controller.dart';
import 'package:passenger_app/src/map/map_service.dart';
import 'package:passenger_app/src/map/map_view.dart';
import 'package:passenger_app/src/services/location_service.dart';
import 'package:passenger_app/src/services/top_level_providers.dart';
import 'app_drawer.dart';
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

  double? _placeDistance;

  final _destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final locationController = ref.watch(locationProvider);
    final mapController = ref.watch(mapProvider);

    return Scaffold(
      bottomSheet: mapController.destinations.isEmpty
          ? null
          : BottomSheet(
              enableDrag: false,
              onClosing: () {
                mapController.clearDestinations();
              },
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4),
                  child: mapController.destinations.isEmpty ||
                          _placeDistance == null
                      ? loadingIndicator
                      : PageView(
                          controller: pageController,
                          children: [
                            LocationSetup(
                                mapController: mapController,
                                pageController: pageController,
                                placeDistance: _placeDistance!,
                                myLocation: myLocation),
                            CompleteOrder(
                                mapController: mapController,
                                pageController: pageController,
                                placeDistance: _placeDistance!,
                                myLocation: myLocation),
                          ],
                        ),
                );
              },
            ),
      extendBodyBehindAppBar: true,
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
                              maxHeight: mapController.destinations.isEmpty
                                  ? MediaQuery.of(context).size.height
                                  : MediaQuery.of(context).size.height * 0.6),
                          child: MapView(
                              myLocation: locationController.myLocation,
                              polylines: mapController.polylines,
                              markers: mapController.markers),
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
                          await Geolocator.openAppSettings();
                          await Geolocator.openLocationSettings();
                          setState(() {});
                        },
                        child: const Text("Request permission"),
                      ),
                      TextButton(
                        onPressed: () async {
                          setState(() {});
                        },
                        child: const Text("Refresh"),
                      ),
                    ],
                  ),
                );
              }
            }),
            if (mapController.destinations.isEmpty)
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

  // Widget showLocationBottomSheet(
  //     MapController mapController, BuildContext context) {
  //   return
  // }

  void placePickerHandler(
      MapController mapController, LocationService locationController) async {
    LatLng? selectedLocation = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => PlacePicker()));
    if (selectedLocation != null) {
      mapController.addDestination(
        selectedLocation,
      );
      _placeDistance = await mapController.calculateDistance(
          locationController.myLocation, selectedLocation);
      mapController.calculatePolyline(
          locationController.myLocation, selectedLocation, <LatLng>[]);
    }
  }
}

class LocationSetup extends StatelessWidget {
  const LocationSetup({
    Key? key,
    required this.mapController,
    required this.pageController,
    required double placeDistance,
    required this.myLocation,
  })  : _placeDistance = placeDistance,
        super(key: key);

  final MapController mapController;
  final PageController pageController;
  final double _placeDistance;
  final LatLng? myLocation;

  @override
  Widget build(BuildContext context) {
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
            const Card(
              child: ListTile(
                title: Text("My Location"),
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            ...mapController.destinations.map(((e) => Card(
                    child: ListTile(
                  title: Text(e.item1),
                )))),
            if (_placeDistance != null)
              Text(
                "${_placeDistance.toStringAsFixed(3)} kilometers",
                style: Theme.of(context).textTheme.headline6,
              ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                  onPressed: (myLocation != null &&
                          mapController.destinations.isNotEmpty)
                      ? () async {
                          // pageController.nextPage(
                          //     duration: Duration(milliseconds: 10),
                          //     curve: SawTooth(1));
                          // mapController.calculatePolyline(
                          //     myLocation!,
                          //     mapController.destinations.first.item2,
                          //     <LatLng>[]);
                        }
                      : null,
                  child: const Text("Next")),
            ),
            TextButton(
                onPressed: () => mapController.clearDestinations(),
                child: Text("Cancel")),
          ],
        ),
      ),
    );
  }
}

class CompleteOrder extends StatelessWidget {
  const CompleteOrder({
    Key? key,
    required this.mapController,
    required this.pageController,
    required double placeDistance,
    required this.myLocation,
  })  : _placeDistance = placeDistance,
        super(key: key);

  final MapController mapController;
  final PageController pageController;
  final double _placeDistance;
  final LatLng? myLocation;

  @override
  Widget build(BuildContext context) {
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
            Text("Select a car"),
            const SizedBox(
              height: 15.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                    visualDensity: VisualDensity.comfortable,
                    label: Column(
                      children: [
                        const Text("Regular"),
                        Text("${(60 + _placeDistance * 10).truncate()} ETB"),
                      ],
                    ),
                    onSelected: (val) {},
                    selected: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                    label: const Text("Mid-size"),
                    onSelected: (val) {},
                    selected: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                    label: const Text("Minibus"),
                    onSelected: (val) {},
                    selected: false,
                  ),
                ),
              ],
            ),
            if (_placeDistance != null)
              Text(
                "${_placeDistance.toStringAsFixed(3)} kilometers",
                style: Theme.of(context).textTheme.headline6,
              ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                  onPressed: (myLocation != null &&
                          mapController.destinations.isNotEmpty)
                      ? () async {
                          // print(await ref
                          //     .read(mapProvider)
                          //     .calculateDistance(
                          //         myLocation!, myDestination!));
                        }
                      : null,
                  child: const Text("Order now")),
            ),
            TextButton(
                onPressed: () => pageController.previousPage(
                    duration: Duration(milliseconds: 10), curve: SawTooth(1)),
                child: Text("Back")),
          ],
        ),
      ),
    );
  }
}
