import 'dart:async';

import 'package:common/dio_client.dart';
import 'package:common/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/src/booked-ride/booked_ride.dart';
import 'package:passenger_app/src/booking-request/booking_request.dart';
import 'package:passenger_app/src/booking-request/booking_request_service.dart';
import 'package:passenger_app/src/booking-request/trip_route.dart';
import 'package:passenger_app/src/booking/booking.dart';
import 'package:passenger_app/src/map/map_service.dart';
import 'package:passenger_app/src/services/booking_data.dart';
import 'package:passenger_app/src/services/location_service.dart';
import 'package:passenger_app/src/services/place_service.dart';
import 'package:tuple/tuple.dart';

class HomeController with ChangeNotifier {
  Place? origin;

  List<Package>? price;

  ChangeNotifierProviderRef ref;

  HomeController(this._bookingRequestService, this.ref);

  final BookingRequestService _bookingRequestService;

  bool isLoading = false;
  TripRoute? tripRoute;

  List<Place> destinations = [];
  List<Marker> markers = [];
  Map<PolylineId, Polyline> polylines = {};

  late GoogleMapController controller;

  Future<TripRoute> calculatePolyline(
      LatLng origin, LatLng destination, List<LatLng> wayPoints) async {
    Map json = await _bookingRequestService.getPolyline(
        origin, destination, wayPoints);

    tripRoute = TripRoute.fromJson(json['polyline']);
    Map packages = json['price'];
    price = packages.entries
        .map((package) => Package(package.key, package.value))
        .toList();
    return tripRoute!;
  }

  void addDestination(Place destination) {
    destinations.add(destination);
    markers.add(
      Marker(
        markerId: MarkerId(destination.formatted_address),
        position: destination.location,
      ),
    );
    notifyListeners();
  }

  void removeDestination(Place destination) {
    destinations.remove(destination);
    markers.removeWhere(
        ((element) => element.markerId.value == destination.formatted_address));
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
      TripRoute route = await calculatePolyline(origin, destination, waypoints);
      Polyline polyline =
          MapService.decodePolyline(route.polyline, route.polylineId);
      polylines[polyline.polylineId] = polyline;

      MapService.updateCameraToPositions(
          route.northeastbound, route.southwestbound, controller);
      isLoading = false;
      notifyListeners();
      return route.distance;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return Future.error(e);
    }
  }

  Future<bool> bookTrip(String polylineId, String capacity) async {
    isLoading = true;
    notifyListeners();
    try {
      Map json =
          await _bookingRequestService.requestBooking(polylineId, capacity);
      ref.read(bookingDataProvider).getBookingData();
      // setActiveBooking(Booking(
      //     bookingRequest: BookingRequest.fromJson(json['bookingRequest'])));
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void cancelRoute() {
    tripRoute = null;
    clearDestinations();
    clearPolylines();
    notifyListeners();
  }
}

final homeProvider = ChangeNotifierProvider(((ref) {
  return HomeController(
      BookingRequestService(ref.read(dioClientProvider)), ref);
}));
