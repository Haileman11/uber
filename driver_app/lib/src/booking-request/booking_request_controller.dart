import 'dart:async';
import 'package:common/dio_client.dart';
import 'package:common/services/navigator_service.dart';
import 'package:common/services/notification_service.dart';
import 'package:driver_app/src/booked-ride/booked_ride.dart';
import 'package:driver_app/src/booking-request/booking_request_view.dart';
import 'package:driver_app/src/map/map_controller.dart';
import 'package:driver_app/src/services/location_service.dart';
import 'package:driver_app/src/booking-request/booking_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';
import 'booking_request_service.dart';

class BookingRequestController with ChangeNotifier {
  BookingRequest? bookingRequest;
  Map? bookedRideJson;

  final BookingRequestService _bookingRequestService;
  final MapController mapController;
  LocationService locationService;

  final NavigationService navigatorService;

  BookingRequestController(this._bookingRequestService, Map? bookingRequestJson,
      this.mapController, this.locationService, this.navigatorService) {
    if (bookingRequestJson != null) {
      bookingRequest = BookingRequest.fromJson(bookingRequestJson);
      navigatorService
          .navigateTo(MaterialPageRoute(builder: (_) => BookingRequestView()));
      mapController.updateCameraToPositions(
          bookingRequest!.origin, bookingRequest!.destination);

      mapController.destinations
          .add(Tuple2("destination", bookingRequest!.destination));
      mapController.decodePolyline(bookingRequest!.polyline, "polylineId");
    }
  }

  Future<void> acceptBookingRequest(bool acceptRequest) async {
    try {
      bookedRideJson = await _bookingRequestService.acceptBookingRequest(
          bookingRequest!.bookingRequestId, acceptRequest);
      bookingRequest = null;
      notifyListeners();
    } catch (e) {}
  }
}

final bookingRequestProvider = ChangeNotifierProvider(((ref) {
  return BookingRequestController(
    BookingRequestService(ref.read(dioClientProvider)),
    ref.watch(notificationProvider).bookingRequestJson,
    ref.read(mapProvider),
    ref.read(locationProvider),
    ref.read(navigationProvider),
  );
}));
