import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:driver_app/src/services/location_service.dart';
import 'app_drawer.dart';
import 'search.dart';

class Homepage extends ConsumerStatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<Homepage>
    with WidgetsBindingObserver {
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  String? currentAddress;

  late String _darkMapStyle;

  late String _lightMapStyle;

  @override
  void initState() {
    super.initState();
    _loadMapStyles();
    // WidgetsBinding.instance!.addObserver(this);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      myLocation = await ref.read(locationProvider).getMyLocation();
    });
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      _setMapStyle();
    });
  }

  Future _setMapStyle() async {
    final controller = await _controller.future;
    final theme = WidgetsBinding.instance!.window.platformBrightness;
    if (theme == Brightness.dark) {
      controller.setMapStyle(_darkMapStyle);
    } else {
      controller.setMapStyle(_lightMapStyle);
    }
  }

  Future _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/map_styles/dark.json');
    _lightMapStyle =
        await rootBundle.loadString('assets/map_styles/light.json');
  }

  LatLng? myLocation;
  LatLng? myDestination;
  final Completer<GoogleMapController> _controller = Completer();
  // ImageConfiguration configuration = ;
  List<Marker> _markers = [];
  String? _placeDistance;

  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  String googleAPiKey = "AIzaSyAZncMtP-Cfxml3YvAtKLL4uOEeGub4Zrc";
  String googleDirectionsAPiKey = "AIzaSyBRErov981d9m8yhEyHOD7FVPQtfuO7OsI";

  final _destinationController = TextEditingController();

  _createPolylines(double startLatitude, double startLongitude,
      double destinationLatitude, double destinationLongitude) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleDirectionsAPiKey,
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
    print(result.points);
  }

  Future<bool> _calculateDistance() async {
    try {
      print(myLocation);
      print(myDestination);
      double startLatitude = myLocation!.latitude;
      double startLongitude = myLocation!.longitude;
      double destinationLatitude = myDestination!.latitude;
      double destinationLongitude = myDestination!.longitude;

      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // Accommodate the two locations within the
      // camera view of the map
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
        print('DISTANCE: $_placeDistance km');
      });

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void getAddress(LatLng currentPosition) async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          currentPosition.latitude, currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        // _destinationController.text = currentAddress!;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<List<Marker>> loadMarkers() async {
    myIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(24, 24)),
        Platform.isIOS
            ? 'assets/images/car-ios-32.png'
            : 'assets/images/car-android-128.png');
    return [
      Marker(
          markerId: const MarkerId("Car 1"),
          position: const LatLng(9.01, 38.78),
          icon: myIcon),
      Marker(
          markerId: const MarkerId("Car 2"),
          position: const LatLng(9.02, 38.78),
          icon: myIcon),
      Marker(
          markerId: const MarkerId("Car 3"),
          position: const LatLng(9.03, 38.78),
          icon: myIcon)
    ];
    // String imgurl = "https://www.fluttercampus.com/img/car.png";
    // Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imgurl)).load(imgurl))
    //     .buffer
    //     .asUint8List();
    // myIcon = BitmapDescriptor.fromBytes(bytes);
    // return _markers.map((e) => e.copyWith(iconParam: myIcon)).toList();
  }

  // void _onMapCreated(GoogleMapController _cntlr)
  // {
  //   _controller = _cntlr;
  //   _location.onLocationChanged.listen((l) {
  //     _controller.animateCamera(
  //       CameraUpdate.newCameraPosition(
  //         CameraPosition(target: LatLng(l.latitude, l.longitude),zoom: 15),
  //         ),
  //     );
  //   });
  // }
  late BitmapDescriptor myIcon;

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: AppDrawer(),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Builder(builder: (context) {
              if (ref.watch(locationProvider).serviceEnabled == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator.adaptive(),
                    ],
                  ),
                );
              } else if (ref.watch(locationProvider).serviceEnabled!) {
                return GoogleMap(
                  polylines: Set<Polyline>.of(polylines.values),
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  markers: _markers.toSet(),
                  onTap: (LatLng latLng) {
                    print(latLng.toString());
                    setState(() {
                      myDestination = latLng;
                      getAddress(latLng);
                      if (_markers
                          .contains((e) => e.markerId.value == "destination")) {
                        _markers
                            .firstWhere(
                                (e) => e.markerId.value == "destination")
                            .copyWith(positionParam: latLng);
                      } else {
                        _markers.add(
                          Marker(
                            markerId: const MarkerId("destination"),
                            position: latLng,
                          ),
                        );
                      }
                    });
                  },
                  onMapCreated: (GoogleMapController controller) async {
                    _controller.complete(controller);
                    var markers = await loadMarkers();
                    await _setMapStyle();
                    setState(() {
                      _markers = markers;
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: myLocation!,
                    // LatLng(9.02484323873786, 38.78085709626648),
                    zoom: 16.0,
                  ),
                );
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
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: AppBar(
                    backgroundColor: _theme.backgroundColor,
                    elevation: 0.0,
                    leading: IconButton(
                      onPressed: () {
                        _scaffoldKey.currentState!.openDrawer();
                      },
                      icon: const Icon(
                        Icons.menu,
                      ),
                    ),
                    title: InkWell(
                      onTap: () =>
                          showSearch(context: context, delegate: DataSearch()),
                      child: TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: "Where to?",
                          suffixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        controller: _destinationController,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                      if (myDestination != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: 10.0,
                            ),
                            Card(
                              child: ListTile(
                                title: Text("My Location"),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Card(
                              child: ListTile(
                                title: Text(
                                    currentAddress ?? myDestination.toString()),
                              ),
                            ),
                            if (_placeDistance != null)
                              Text(
                                "$_placeDistance kilometers",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ElevatedButton(
                                  onPressed: (myLocation != null &&
                                          myDestination != null)
                                      ? () async {
                                          print(await _calculateDistance());
                                        }
                                      : null,
                                  child: Text("Order now")),
                            )
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
