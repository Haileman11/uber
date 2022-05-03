import 'package:common/dio_client.dart';
import 'package:dio/dio.dart';

class BookedRideService {
  /// Persists the user's preferred ThemeMode to local or remote storage.
  late DioClient _dioClient;
  static const acceptBookingUrl = "Request/accept-booking-request";
  BookedRideService(this._dioClient);

  Future<Map> acceptBookingRequest(
    String bookingId,
    bool acceptRequest,
  ) async {
    try {
      Response response;
      response = await _dioClient.dio.post(acceptBookingUrl,
          data: {
            "requestAccepted": acceptRequest,
            "bookingRequestId": bookingId
          },
          options: Options(headers: {'requiresToken': true}));
      return response.data;
    } catch (e) {
      print(e);
      return {};
    }
  }
}
