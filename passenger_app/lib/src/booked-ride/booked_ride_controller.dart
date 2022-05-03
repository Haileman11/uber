import 'dart:async';

import 'package:common/dio_client.dart';
import 'package:common/services/notification_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/src/booked-ride/booked_ride.dart';
import 'package:passenger_app/src/map/map_controller.dart';
import 'package:passenger_app/src/services/location_service.dart';
import 'package:tuple/tuple.dart';
import 'booked_ride_service.dart';

class BookedRideController with ChangeNotifier {
  final BookedRideService _bookedRideService;

  final MapController mapController;
  LocationService locationService;

  BookedRide? ongoingRide;
  BookedRide? completeRide;

  BookedRideController(NotificationService notificationService,
      this._bookedRideService, this.mapController, this.locationService) {
    if (notificationService.completeRideJson != null) {
      completeRide = BookedRide.fromJson(notificationService.completeRideJson!);
      drawPolyline(completeRide!);
    } else if (notificationService.ongoingRideJson != null) {
      ongoingRide = BookedRide.fromJson(notificationService.ongoingRideJson!);
      drawPolyline(ongoingRide!);
    }
  }
  drawPolyline(BookedRide bookedRide) {
    mapController.updateCameraToPositions(
        bookedRide.origin, bookedRide.destination);
    // mapController.destinations
    //     .add(Tuple2("destination", bookedRide.destination));
    mapController.decodePolyline(bookedRide.polyline, "polylineId");
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
        mapController.addPolyline(id, polyline);
        mapController.controller
            .animateCamera(CameraUpdate.newLatLngZoom(point, 15));
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
      List<LatLng> points = [];
      subscription!.cancel();
      List<LatLng> path =
          mapController.polylines[PolylineId('currentPath')]!.points;
    } catch (e) {}
    // notifyListeners();
  }
}

final bookedRideProvider = ChangeNotifierProvider(((ref) {
  return BookedRideController(
      ref.watch(notificationProvider),
      BookedRideService(ref.read(dioClientProvider)),
      ref.read(mapProvider),
      ref.read(locationProvider));
}));
