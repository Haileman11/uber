import 'dart:async';

import 'package:common/dio_client.dart';
import 'package:common/services/navigator_service.dart';
import 'package:driver_app/src/booked-ride/booked_ride.dart';
import 'package:driver_app/src/booking-request/booking_request_controller.dart';
import 'package:driver_app/src/map/map_controller.dart';
import 'package:driver_app/src/map/map_service.dart';
import 'package:driver_app/src/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tuple/tuple.dart';
import 'booked_ride_service.dart';
import 'ui/booked_ride_view.dart';

class BookedRideController with ChangeNotifier {
  final BookedRideService _bookedRideService;

  LocationService locationService;

  BookedRide? bookedRide;
  BookedRide? completeRide;

  late GoogleMapController controller;
  Set<Tuple2<String, LatLng>> destinations = {};
  List<Marker> markers = [];
  Map<PolylineId, Polyline> polylines = {};

  BookedRideController(
      this.bookedRide,
      this._bookedRideService,
      this.locationService,
      NavigationService navigationService,
      MapController mapController) {
    if (bookedRide != null) {
      destinations.add(Tuple2("destination", bookedRide!.destination));
      Polyline polyline =
          MapService.decodePolyline(bookedRide!.polyline, "polylineId");
      polylines[polyline.polylineId] = polyline;
      markers.add(
          Marker(markerId: MarkerId('myLocation'), icon: mapController.myIcon));
    }
  }

  StreamSubscription? subscription;

  Future<void> startTrackingTrip(
      // String bookingId, bool acceptRequest
      ) async {
    try {
      List<LatLng> points = [];
      locationService.startLocationStream();
      PolylineId id = PolylineId("currentPath");
      subscription = locationService.locationStream.listen((point) {
        points.add(point);
        Polyline polyline = Polyline(
          polylineId: id,
          color: Colors.blue,
          points: points,
          width: 3,
        );
        addPolyline(id, polyline);
        controller.animateCamera(CameraUpdate.newLatLngZoom(point, 15));
        print(points);
      }, onError: (e) {
        print(e);
      });
    } catch (e) {}
    // notifyListeners();
  }

  Future<void> completeTrip(
      // String bookingId, bool acceptRequest
      ) async {
    try {
      locationService.stopLocationStream();
      subscription!.cancel();

      List<LatLng> points = polylines[PolylineId('currentPath')]!.points;
      List<List<double>> coordinates =
          points.map((e) => [e.latitude, e.longitude]).toList();
      String encodedPolyline = MapService.encodePoly(coordinates, 5);
      completeRide = await _bookedRideService.completeTrip(
          bookedRide!.bookedRideId, encodedPolyline);
      notifyListeners();
    } catch (e) {}
    // notifyListeners();
  }

  void addPolyline(PolylineId polylineId, Polyline polyline) {
    polylines[polylineId] = polyline;
    notifyListeners();
  }

  void clearDestinations() {
    markers.clear();
    destinations.clear();
    notifyListeners();
  }

  void clearPolylines() {
    polylines.clear();
    notifyListeners();
  }
}

final bookedRideProvider = ChangeNotifierProvider(((ref) {
  return BookedRideController(
      ref.watch(bookingRequestProvider).bookedRide,
      BookedRideService(ref.read(dioClientProvider)),
      ref.read(locationProvider),
      ref.read(navigationProvider),
      ref.read(mapProvider));
}));
