import 'dart:async';

import 'package:common/dio_client.dart';
import 'package:common/services/notification_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/src/booked-ride/booked_ride.dart';
import 'package:passenger_app/src/booking-request/booking_request_controller.dart';
import 'package:passenger_app/src/booking/booking.dart';
import 'package:passenger_app/src/map/map_controller.dart';
import 'package:passenger_app/src/map/map_service.dart';
import 'package:passenger_app/src/services/booking_data.dart';
import 'package:passenger_app/src/services/location_service.dart';
import 'package:passenger_app/src/services/place_service.dart';
import 'package:passenger_app/src/services/top_level_providers.dart';
import 'package:tuple/tuple.dart';
import 'booked_ride_service.dart';

class BookedRideController with ChangeNotifier {
  final BookedRideService _bookedRideService;

  final MapController mapController;
  LocationService locationService;

  Booking? activeBooking;

  BookedRideController(this.activeBooking, this._bookedRideService,
      this.mapController, this.locationService, MapController read) {
    if (activeBooking != null && activeBooking!.bookedRide != null) {
      destinations.add(Place(activeBooking!.bookingRequest.route.endaddress,
          activeBooking!.bookingRequest.route.destination));
      Polyline polyline = MapService.decodePolyline(
          activeBooking!.bookingRequest.route.polyline,
          activeBooking!.bookingRequest.route.polylineId);
      polylines[polyline.polylineId] = polyline;
    }
  }
  List<Place> destinations = [];
  List<Marker> markers = [];
  Map<PolylineId, Polyline> polylines = {};

  late GoogleMapController controller;

  drawPolyline(Booking booking) {
    MapService.updateCameraToPositions(booking.bookingRequest.route.origin,
        booking.bookingRequest.route.destination, controller);
    Polyline polyline = MapService.decodePolyline(
        booking.bookingRequest.route.polyline, "polylineId");
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

  void cancelRide() {}
}

final bookedRideProvider = ChangeNotifierProvider(((ref) {
  return BookedRideController(
      ref.watch(bookingDataProvider).activeBooking,
      BookedRideService(ref.read(dioClientProvider)),
      ref.read(mapProvider),
      ref.read(locationProvider),
      ref.read(mapProvider));
}));
