import 'package:common/dio_client.dart';
import 'package:common/services/notification_service.dart';
import 'package:dio/dio.dart';
import 'package:driver_app/src/booking-request/booking_request_service.dart';
import 'package:driver_app/src/booking/booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingDataProvider with ChangeNotifier {
  late DioClient _dioClient;
  Booking? activeBooking;
  bool activityStatus = false;
  BookingDataProvider(
    this._dioClient,
    Map? bookingJson,
  ) {
    if (bookingJson != null) {
      activeBooking = Booking.fromJson(bookingJson);
    }
  }
  static const getBookingDataUrl = "Request/get-booking-data";
  static const changeDriverStatusUrl = "Request/change-driver-status";
  static const updateDriverLocation = "Request/update-driver-location";

  Future<void> getBookingData() async {
    try {
      Response response;
      response = await _dioClient.dio.get(getBookingDataUrl,
          options: Options(headers: {'requiresToken': true}));
      print(response.data);
      if (response.data['activeBooking'] != null) {
        activeBooking = Booking.fromJson(response.data['activeBooking']);
      }
      activityStatus = response.data['activityStatus'];
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> toggleActivityStatus(LatLng location) async {
    try {
      Response response;
      response = await _dioClient.dio.post(changeDriverStatusUrl,
          data: {
            "isActive": !activityStatus,
            "currentLocation": location.toCustomJson()
          },
          options: Options(headers: {'requiresToken': true}));
      activityStatus = response.data['activityStatus'];
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateLocation(LatLng location) async {
    try {
      Response response;
      response = await _dioClient.dio.post(updateDriverLocation,
          data: {"currentLocation": location.toCustomJson()},
          options: Options(headers: {'requiresToken': true}));
      activityStatus = response.data['activityStatus'];
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void setActiveBooking(Booking booking) {
    activeBooking = booking;
    notifyListeners();
  }

  Stream<Booking?> activeBookingStateChanges() {
    return Stream.value(activeBooking);
  }
}

final bookingDataProvider =
    ChangeNotifierProvider(((ref) => BookingDataProvider(
          ref.read(dioClientProvider),
          ref.watch(notificationProvider).bookingJson,
        )));
