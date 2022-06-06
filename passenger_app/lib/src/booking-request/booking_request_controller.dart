import 'dart:async';

import 'package:common/dio_client.dart';
import 'package:common/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/src/booked-ride/booked_ride.dart';
import 'package:passenger_app/src/booking-request/booking_request.dart';
import 'package:passenger_app/src/booking-request/booking_request_service.dart';
import 'package:passenger_app/src/booking/booking.dart';
import 'package:passenger_app/src/map/map_service.dart';
import 'package:passenger_app/src/services/booking_data.dart';
import 'package:passenger_app/src/services/location_service.dart';
import 'package:passenger_app/src/services/place_service.dart';
import 'package:tuple/tuple.dart';

import 'trip_route.dart';

class BookingRequestController with ChangeNotifier {
  Place? origin;

  List<Package>? price;

  ChangeNotifierProviderRef ref;

  BookingRequestController(
      this._bookingRequestService, this.activeBooking, this.ref) {
    if (activeBooking != null && activeBooking!.bookedRide == null) {
      destinations.add(Place(activeBooking!.bookingRequest.route.endaddress,
          activeBooking!.bookingRequest.route.destination));
      Polyline polyline = MapService.decodePolyline(
          activeBooking!.bookingRequest.route.polyline,
          activeBooking!.bookingRequest.route.polylineId);
      polylines[polyline.polylineId] = polyline;
    }
  }

  final BookingRequestService _bookingRequestService;

  bool isLoading = false;
  Booking? activeBooking;

  List<Place> destinations = [];
  List<Marker> markers = [];
  Map<PolylineId, Polyline> polylines = {};

  late GoogleMapController controller;

  Future<bool> cancelBookingRequest() async {
    isLoading = true;
    notifyListeners();
    try {
      Map json = await _bookingRequestService
          .cancelBookingRequest(activeBooking!.bookingRequest.bookingRequestId);
      ref.read(bookingDataProvider).activeBooking = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
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
}

final bookingRequestProvider = ChangeNotifierProvider(((ref) {
  return BookingRequestController(
      BookingRequestService(ref.read(dioClientProvider)),
      ref.watch(bookingDataProvider).activeBooking,
      ref);
}));
