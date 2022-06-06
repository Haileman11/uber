import 'package:common/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingRequestService {
  late DioClient _dioClient;
  static const calculatePolylineUrl = "Request/calculate-polyline";
  static const bookRequestUrl = "Request/request-booking";
  static const cancelBookingRequestUrl = "Request/cancel-booking-request";
  BookingRequestService(this._dioClient);

  Future<Map> requestBooking(
    String polylineId,
    String capacity,
  ) async {
    try {
      Response response;
      response = await _dioClient.dio.post(bookRequestUrl,
          data: {"carType": capacity, "polyLineId": polylineId},
          options: Options(headers: {'requiresToken': true}));
      return response.data;
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future<Map> getPolyline(
    LatLng origin,
    LatLng destination,
    List<LatLng> wayPoints,
  ) async {
    try {
      List wayPointsArray = ["ds"];
      for (var point in wayPoints) {
        wayPointsArray.add("'${point.latitude},${point.longitude}'");
      }

      var data = {
        "origin": origin.toCustomJson(),
        "destination": destination.toCustomJson(),
        if (wayPoints.isNotEmpty)
          "wayPoints": wayPoints.map((e) => e.toCustomJson()).toList()
      };
      print(data);
      Response response = await _dioClient.dio.post(calculatePolylineUrl,
          data: data, options: Options(headers: {'requiresToken': true}));
      return response.data;
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }

  Future<Map> cancelBookingRequest(String bookingRequestId) async {
    try {
      Response response = await _dioClient.dio.post(cancelBookingRequestUrl,
          data: {
            "bookingRequestId": bookingRequestId,
          },
          options: Options(headers: {'requiresToken': true}));
      return response.data;
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }
}

extension ToJsonExtension on LatLng {
  toCustomJson() {
    return {"latitude": latitude, "longitude": longitude};
  }
}
