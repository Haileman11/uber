import 'package:common/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingRequestService {
  late DioClient _dioClient;
  static const calculatePolylineUrl = "Request/calculate-polyline";
  static const bookRequestUrl = "Request/request-booking";
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

      Response response = await _dioClient.dio.post(calculatePolylineUrl,
          data: {
            "origin": {
              "latitude": origin.latitude,
              "longitude": origin.longitude
            },
            "destination": {
              "latitude": destination.latitude,
              "longitude": destination.longitude
            },
            "wayPoints": ["string"]
          },
          options: Options(headers: {'requiresToken': true}));
      return response.data;
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }
}
