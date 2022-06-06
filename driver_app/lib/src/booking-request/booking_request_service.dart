import 'package:common/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingRequestService {
  /// Persists the user's preferred ThemeMode to local or remote storage.
  late DioClient _dioClient;
  static const acceptBookingUrl = "Request/accept-booking-request";
  BookingRequestService(this._dioClient);

  Future<Map> acceptBookingRequest(
    String bookingId,
    bool acceptRequest,
    LatLng driverLocation,
  ) async {
    Response response;
    try {
      response = await _dioClient.dio.post(acceptBookingUrl,
          data: {
            "requestAccepted": acceptRequest,
            "bookingRequestId": bookingId,
            "driverLocation": driverLocation.toCustomJson()
          },
          options: Options(headers: {'requiresToken': true}));
      return response.data['booking'];
    } catch (e) {
      print(e);
      return {};
    }
  }
}

extension ToJsonExtension on LatLng {
  toCustomJson() {
    return {"latitude": latitude, "longitude": longitude};
  }
}
