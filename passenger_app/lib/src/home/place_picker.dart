import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/src/map/map_service.dart';
import 'package:passenger_app/src/map/map_view.dart';
import 'package:passenger_app/src/services/location_service.dart';

class PlacePicker extends ConsumerStatefulWidget {
  const PlacePicker({Key? key}) : super(key: key);

  @override
  ConsumerState<PlacePicker> createState() => _PlacePickerState();
}

class _PlacePickerState extends ConsumerState<PlacePicker> {
  late CameraPosition cameraPosition;
  @override
  void initState() {
    cameraPosition =
        CameraPosition(target: ref.read(locationProvider).myLocation);
    super.initState();
  }

  String? location;

  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final locationController = ref.watch(locationProvider);
    return Scaffold(
      body: Stack(
        children: [
          Builder(builder: (context) {
            if (locationController.serviceEnabled == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator.adaptive(),
                  ],
                ),
              );
            } else if (locationController.serviceEnabled!) {
              return MapView(
                myLocation: locationController.myLocation,
                isPlacePicker: true,
                onCameraMove: (CameraPosition currentCameraPosition) {
                  cameraPosition = currentCameraPosition; //when map is dragging
                },
                onCameraIdle: () async {
                  //when map drag stops
                  String address = await MapService.getAddress(
                    cameraPosition.target,
                  );
                  setState(() {
                    //get place name from lat and lang
                    location = address;
                  });
                },
              );
            } else {
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Location is disabled."),
                    TextButton(
                      onPressed: () async {
                        await Geolocator.openAppSettings();
                        await Geolocator.openLocationSettings();
                        setState(() {});
                      },
                      child: const Text("Request permission"),
                    ),
                    TextButton(
                      onPressed: () async {
                        setState(() {});
                      },
                      child: const Text("Refresh"),
                    ),
                  ],
                ),
              );
            }
          }),
          const Center(
              child: Icon(
            Icons.location_pin,
            size: 80,
          )),
          Positioned(
              //widget to display location name
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Card(
                      child: Container(
                          padding: EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width - 40,
                          child: ListTile(
                            leading: Icon(
                              Icons.location_pin,
                            ),
                            title: Text(
                              location ?? "",
                              style: TextStyle(fontSize: 18),
                            ),
                            dense: true,
                          )),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(cameraPosition.target);
                        },
                        child: Text("Select Location"))
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
