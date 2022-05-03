import 'package:common/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/src/booking-request/booking_request.dart';
import 'package:passenger_app/src/booking-request/booking_request_service.dart';

class BookingRequestController with ChangeNotifier {
  BookingRequestController(this._bookingRequestService, this.ref);
  final BookingRequestService _bookingRequestService;

  ChangeNotifierProviderRef<BookingRequestController> ref;
  bool isLoading = false;
  BookingRequest? bookingRequest;
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
    // notifyListeners();
  }
}

final bookingRequestProvider = ChangeNotifierProvider(((ref) {
  return BookingRequestController(
      BookingRequestService(ref.read(dioClientProvider)), ref);
}));
