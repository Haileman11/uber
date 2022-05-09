import 'package:common/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:driver_app/src/booked-ride/booked_ride.dart';

class BookedRideService {
  /// Persists the user's preferred ThemeMode to local or remote storage.
  late DioClient _dioClient;
  static const completeTripUrl = "Request/complete-trip";
  static const getBookedRidesUrl = "Request/get-booked-rides";
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

  Future<List<BookedRide>?> getBookedRides() async {
    try {
      Response response = await _dioClient.dio.get(getBookedRidesUrl,
          options: Options(headers: {'requiresToken': true}));
      var bookedRidesJson = response.data;
      List<BookedRide> bookedRides = bookedRidesJson
          .map<BookedRide>((json) => BookedRide.fromJson(json))
          .toList();
      return bookedRides;
    } catch (e) {
      return null;
    }
  }
}
