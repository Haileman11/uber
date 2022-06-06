import 'package:common/dio_client.dart';
import 'package:common/ui/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:passenger_app/src/booking-request/booking_request_controller.dart';
import 'package:passenger_app/src/booking-request/ui/place_picker.dart';
import 'package:passenger_app/src/map/map_controller.dart';
import 'package:passenger_app/src/services/place_service.dart';

class AddressSearch extends SearchDelegate<Place?> {
  var recent = [
    // 'john do',
    // 'biology',
    // 'astro',
  ];
  List<Suggestion> result = [];

  final String sessionToken;

  BuildContext context;
  AddressSearch(this.sessionToken, this.context);
  @override
  PreferredSizeWidget buildBottom(BuildContext context) {
    return PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: Consumer(builder: (_, ref, child) {
          return TextButton(
              onPressed: () async {
                var selectedLocation = await placePickerHandler(
                    ref.read(mapProvider), this.context);
                if (selectedLocation != null) {
                  close(this.context, selectedLocation);
                }
              },
              child: Text('Set location on map'));
        }));
  }

  Future<Place?> placePickerHandler(
      MapController mapController, BuildContext context) async {
    Place? selectedLocation = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => PlacePicker()));
    return selectedLocation;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    FocusScope.of(context).unfocus();

    return loadResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var suggestions = [];
    return query.isEmpty
        ? ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (ctx, index) => ListTile(
              leading: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  child: Icon(Icons.location_pin),
                ),
              ),
              title: Text("${result[index].description}"),
            ),
          )
        : loadResults(context);
  }

  Widget loadResults(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return FutureBuilder(
          future: PlaceApiProvider(ref.read(dioClientProvider), sessionToken)
              .fetchSuggestions(query),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              result = snapshot.data as List<Suggestion>;
              return result.isEmpty
                  ? Center(
                      child: Text(
                      "No results",
                      style: Theme.of(context).textTheme.headline6,
                    ))
                  : ListView.builder(
                      itemCount: result.length,
                      itemBuilder: (ctx, index) => ListTile(
                        onTap: () async {
                          final place = await PlaceApiProvider(
                                  ref.read(dioClientProvider), sessionToken)
                              .getPlaceDetailFromId(result[index].placeId);
                          close(context, place);
                        },
                        leading: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            child: Icon(Icons.location_pin),
                          ),
                        ),
                        title: Text("${result[index].description}"),
                      ),
                    );
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                "Error loading the results",
                style: Theme.of(context).textTheme.headline6,
              ));
            }
            return loadingIndicator;
          });
    });
  }
}
