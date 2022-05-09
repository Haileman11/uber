import 'dart:async';
import 'package:common/dio_client.dart';
import 'package:common/services/navigator_service.dart';
import 'package:common/services/notification_service.dart';
import 'package:driver_app/src/booked-ride/booked_ride.dart';
import 'package:driver_app/src/booked-ride/ui/ongoing_ride_view.dart';
import 'package:driver_app/src/booking-request/booking_request_view.dart';
import 'package:driver_app/src/map/map_controller.dart';
import 'package:driver_app/src/map/map_service.dart';
import 'package:driver_app/src/services/location_service.dart';
import 'package:driver_app/src/booking-request/booking_request.dart';
import 'package:driver_app/src/services/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tuple/tuple.dart';
import 'booking_request_service.dart';

class BookingRequestController with ChangeNotifier {
  BookingRequest? bookingRequest;
  BookedRide? bookedRide;

  final BookingRequestService _bookingRequestService;
  LocationService locationService;

  final NavigationService navigatorService;
  late GoogleMapController controller;

  Set<Tuple2<String, LatLng>> destinations = {};
  List<Marker> markers = [];
  Map<PolylineId, Polyline> polylines = {};

  bool isLoading = false;

  BookingRequestController(
      ChangeNotifierProviderRef ref,
      this._bookingRequestService,
      Map? bookingRequestJson,
      this.locationService,
      this.navigatorService) {
    if (bookingRequestJson != null) {
      bookingRequest = BookingRequest.fromJson(bookingRequestJson);
      destinations.add(Tuple2("destination", bookingRequest!.destination));
      Polyline polyline =
          MapService.decodePolyline(bookingRequest!.polyline, "polylineId");
      polylines[polyline.polylineId] = polyline;
    }
  }

  Future<bool> acceptBookingRequest(bool acceptRequest) async {
    try {
      var bookedRideJson = await _bookingRequestService.acceptBookingRequest(
          bookingRequest!.bookingRequestId, acceptRequest);
      bookedRide = BookedRide.fromJson(bookedRideJson);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void addDestination(LatLng currentPosition) async {
    var destinationName = await MapService.getAddress(currentPosition);
    destinations.add(Tuple2(destinationName, currentPosition));
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
    ref,
    BookingRequestService(ref.read(dioClientProvider)),
    ref.watch(bookingRequestJsonProvider),
    ref.read(locationProvider),
    ref.read(navigationProvider),
  );
}));
