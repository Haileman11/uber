import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingRequest {
  late String bookingRequestId;
  late double distance;
  late double price;
  late LatLng origin;
  late LatLng destination;
  late String polyline;

  late String startaddress;
  late String endaddress;

  late LatLng southwestbound;
  late LatLng northeastbound;
  BookingRequest({
    required this.bookingRequestId,
    required this.distance,
    required this.price,
    required this.origin,
    required this.destination,
    required this.polyline,
  });
  BookingRequest.fromJson(json) {
    bookingRequestId = json['bookingRequestId'];
    distance = double.parse(json['distance']);
    price = double.parse(json['price']);
    origin = LatLng(
      double.parse(json['originlatitude']),
      double.parse(json['originlongitude']),
    );
    destination = LatLng(
      double.parse(json['destinationlatitude']),
      double.parse(json['destinationlongitude']),
    );
    southwestbound = LatLng(
      double.parse(json['southwestboundlat']),
      double.parse(json['southwestboundlng']),
    );
    northeastbound = LatLng(
      double.parse(json['northeastboundlat']),
      double.parse(json['northeastboundlng']),
    );
    startaddress = json["startAddress"];
    endaddress = json["endAddress"];
    polyline = json['polyline'];
  }
}
