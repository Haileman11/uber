import 'dart:async';

import 'package:common/dio_client.dart';
import 'package:common/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/src/booked-ride/booked_ride.dart';
import 'package:passenger_app/src/booking-request/booking_request.dart';
import 'package:passenger_app/src/booking-request/booking_request_service.dart';
import 'package:passenger_app/src/map/map_service.dart';
import 'package:passenger_app/src/services/location_service.dart';
import 'package:tuple/tuple.dart';

class BookingRequestController with ChangeNotifier {
  BookedRide? bookedRide;

  Tuple2<String, LatLng>? origin;

  BookingRequestController(
    this._bookingRequestService,
  ) {}

  final BookingRequestService _bookingRequestService;

  bool isLoading = false;
  BookingRequest? bookingRequest;

  Set<Tuple2<String, LatLng>> destinations = {};
  List<Marker> markers = [];
  Map<PolylineId, Polyline> polylines = {};

  late GoogleMapController controller;

  Future<BookingRequest> calculatePolyline(
      LatLng origin, LatLng destination, List<LatLng> wayPoints) async {
    Map json = await _bookingRequestService.getPolyline(
        origin, destination, wayPoints);

    bookingRequest = BookingRequest.fromJson(json);
    return bookingRequest!;
  }

  Future<bool> bookTrip(String polylineId, String capacity) async {
    isLoading = true;
    notifyListeners();
    try {
      Map response =
          await _bookingRequestService.requestBooking(polylineId, capacity);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> addDestination(Tuple2<String, LatLng> destination) async {
    destinations.add(destination);
    markers.add(
      Marker(
        markerId: MarkerId(destination.item1),
        position: destination.item2,
      ),
    );
    notifyListeners();
  }

  void addPolyline(PolylineId polylineId, Polyline polyline) {
    polylines[polylineId] = polyline;
    notifyListeners();
  }

  void clearDestinations() {
    markers.clear();
    destinations.clear();
  }

  void clearPolylines() {
    polylines.clear();
  }

  Future<double> calculateDistance(LatLng origin, LatLng destination,
      {List<LatLng> waypoints = const []}) async {
    isLoading = true;
    notifyListeners();
    try {
      BookingRequest bookingRequest =
          await calculatePolyline(origin, destination, waypoints);
      Polyline polyline = MapService.decodePolyline(
          bookingRequest.polyline, bookingRequest.polylineId);
      polylines[polyline.polylineId] = polyline;

      // MapService.updateCameraToPositions(origin, destination, controller);
      isLoading = false;
      notifyListeners();
      return bookingRequest.distance;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return Future.error(e);
    }
  }
}

final bookingRequestProvider = ChangeNotifierProvider(((ref) {
  return BookingRequestController(
    BookingRequestService(ref.read(dioClientProvider)),
  );
}));
