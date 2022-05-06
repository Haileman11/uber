import 'dart:async';

import 'package:common/dio_client.dart';
import 'package:common/services/notification_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/src/booked-ride/booked_ride.dart';
import 'package:passenger_app/src/booking-request/booking_request_controller.dart';
import 'package:passenger_app/src/map/map_controller.dart';
import 'package:passenger_app/src/map/map_service.dart';
import 'package:passenger_app/src/services/location_service.dart';
import 'package:passenger_app/src/services/top_level_providers.dart';
import 'package:tuple/tuple.dart';
import 'booked_ride_service.dart';

class BookedRideController with ChangeNotifier {
  final BookedRideService _bookedRideService;

  final MapController mapController;
  LocationService locationService;

  BookedRide? ongoingRide;
  BookedRide? completeRide;

  BookedRideController(Map? ongoingRideJson, this._bookedRideService,
      this.mapController, this.locationService, MapController read) {
    if (ongoingRideJson != null) {
      ongoingRide = BookedRide.fromJson(ongoingRideJson);
    }
  }
  Set<Tuple2<String, LatLng>> destinations = {};
  List<Marker> markers = [];
  Map<PolylineId, Polyline> polylines = {};

  late GoogleMapController controller;

  drawPolyline(BookedRide bookedRide) {
    MapService.updateCameraToPositions(
        bookedRide.origin, bookedRide.destination, controller);
    Polyline polyline =
        MapService.decodePolyline(bookedRide.polyline, "polylineId");
    polylines[polyline.polylineId] = polyline;
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
        mapController.controller
            .animateCamera(CameraUpdate.newLatLngZoom(point, 15));
        print(points);
      }, onError: (e) {
        print(e);
      });
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
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: locationService.myLocation, zoom: 15)));
    notifyListeners();
  }

  void clearPolylines() {
    polylines.clear();
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: locationService.myLocation, zoom: 15)));
    notifyListeners();
  }
}

final bookedRideProvider = ChangeNotifierProvider(((ref) {
  return BookedRideController(
      ref.watch(ongoingRideJsonProvider),
      BookedRideService(ref.read(dioClientProvider)),
      ref.read(mapProvider),
      ref.read(locationProvider),
      ref.read(mapProvider));
}));
