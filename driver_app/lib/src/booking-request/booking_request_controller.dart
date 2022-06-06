import 'dart:async';
import 'dart:convert';
import 'package:common/dio_client.dart';
import 'package:common/services/navigator_service.dart';
import 'package:driver_app/src/booking/booking.dart';
import 'package:driver_app/src/map/map_service.dart';
import 'package:driver_app/src/services/booking_data.dart';
import 'package:driver_app/src/services/location_service.dart';
import 'package:driver_app/src/services/place_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'booking_request_service.dart';

class BookingRequestController with ChangeNotifier {
  Booking? activeBooking;

  final BookingRequestService _bookingRequestService;
  LocationService locationService;

  final NavigationService navigatorService;
  late GoogleMapController controller;

  List<Place> destinations = [];
  List<Marker> markers = [];
  Map<PolylineId, Polyline> polylines = {};

  bool isLoading = false;

  ChangeNotifierProviderRef ref;

  BookingRequestController(this._bookingRequestService, this.locationService,
      this.navigatorService, this.activeBooking, this.ref) {
    if (activeBooking != null && activeBooking!.bookedRide == null) {
      destinations.add(Place(activeBooking!.bookingRequest.route.endaddress,
          activeBooking!.bookingRequest.route.destination));
      Polyline polyline = MapService.decodePolyline(
          activeBooking!.bookingRequest.route.polyline,
          activeBooking!.bookingRequest.route.polylineId);
      polylines[polyline.polylineId] = polyline;
    }
  }

  Future<bool> acceptBookingRequest(
      bool acceptRequest, LatLng driverLocation) async {
    try {
      var bookedRideJson = await _bookingRequestService.acceptBookingRequest(
          activeBooking!.bookingRequest.bookingRequestId,
          acceptRequest,
          driverLocation);
      Booking booking = Booking.fromJson(bookedRideJson);
      ref.read(bookingDataProvider).setActiveBooking(booking);
      return true;
    } catch (e) {
      return false;
    }
  }

  void addDestination(LatLng currentPosition) async {
    var destinationName = await MapService.getAddress(currentPosition);
    destinations.add(Place(destinationName, currentPosition));
  }

  void clearDestinations() {
    destinations.clear();
    polylines.clear();
  }

  void addPolyline(PolylineId polylineId, Polyline polyline) {
    polylines[polylineId] = polyline;
    notifyListeners();
  }

  void clearPolylines() {
    polylines.clear();
  }
}

final bookingRequestProvider = ChangeNotifierProvider(((ref) {
  return BookingRequestController(
      BookingRequestService(ref.read(dioClientProvider)),
      ref.read(locationProvider),
      ref.read(navigationProvider),
      ref.read(bookingDataProvider).activeBooking,
      ref);
}));
