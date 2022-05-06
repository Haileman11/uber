import 'package:common/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:driver_app/src/booked-ride/booked_ride.dart';

class BookedRideService {
  /// Persists the user's preferred ThemeMode to local or remote storage.
  late DioClient _dioClient;
  static const completeTripUrl = "Request/complete-trip";
  BookedRideService(this._dioClient);

  Future<BookedRide> completeTrip(
    String bookingId,
    String encodedPolyline,
  ) async {
    try {
      Response response;
      response = await _dioClient.dio.post(completeTripUrl,
          data: {
            "bookedRideId": bookingId,
            "encodedPointsList": encodedPolyline
          },
          options: Options(headers: {'requiresToken': true}));
      return BookedRide.fromJson(response.data);
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }
}
