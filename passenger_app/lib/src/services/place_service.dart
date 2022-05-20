import 'dart:convert';
import 'package:common/dio_client.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  String formatted_address;
  LatLng location;
  Place(
    this.formatted_address,
    this.location,
  );
}

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceApiProvider {
  late DioClient _dioClient;

  final sessionToken;

  PlaceApiProvider(this._dioClient, this.sessionToken);

  String googleAPiKey = "AIzaSyAZncMtP-Cfxml3YvAtKLL4uOEeGub4Zrc";
  String googleDirectionsAPiKey = "AIzaSyBRErov981d9m8yhEyHOD7FVPQtfuO7OsI";
  final apiKey = "AIzaSyBRErov981d9m8yhEyHOD7FVPQtfuO7OsI";

  Future<List<Suggestion>> fetchSuggestions(String input,
      {String lang = "en"}) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&language=$lang&components=country:et&key=$apiKey&sessiontoken=$sessionToken';
    final response = await _dioClient.dio.get(request);

    if (response.statusCode == 200) {
      final result = response.data;
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Place> getPlaceDetailFromId(String placeId) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&sessiontoken=$sessionToken';
    final response = await _dioClient.dio.get(request);

    if (response.statusCode == 200) {
      final result = response.data;
      if (result['status'] == 'OK') {
        final formattedAddress = result['result']['formatted_address'];
        final latitude = result['result']['geometry']['location']['lat'];
        final longitude = result['result']['geometry']['location']['lng'];

        // build result
        final place = Place(formattedAddress, LatLng(latitude, longitude));

        return place;
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
