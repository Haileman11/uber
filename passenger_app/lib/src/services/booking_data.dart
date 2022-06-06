import 'package:common/dio_client.dart';
import 'package:common/services/notification_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passenger_app/src/booking/booking.dart';

class BookingDataProvider with ChangeNotifier {
  late DioClient _dioClient;
  Booking? activeBooking;

  BookingDataProvider(
    this._dioClient,
    Map? bookingJson,
  ) {
    if (bookingJson != null) {
      activeBooking = Booking.fromJson(bookingJson);
    }
  }
  static const getBookingDataUrl = "Request/get-booking-data";
  Future<void> getBookingData() async {
    Response response;
    try {
      response = await _dioClient.dio.get(getBookingDataUrl,
          options: Options(headers: {'requiresToken': true}));
      print(response.data);
      if (response.data['activeBooking'] != null) {
        activeBooking = Booking.fromJson(response.data['activeBooking']);
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void setActiveBooking(Booking? booking) {
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
